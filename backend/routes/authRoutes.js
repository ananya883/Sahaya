import dotenv from "dotenv";
dotenv.config();

import express from "express";
import bcrypt from "bcryptjs";
import nodemailer from "nodemailer";
import User from "../models/User.js";
import PreUser from "../models/preUser.js";

const router = express.Router();

// ------------------------
// Validation Regex
// ------------------------
const emailRegex = /^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$/;
const mobileRegex = /^\d{10}$/;

// ------------------------
// Nodemailer Transporter (Brevo SMTP)
// ------------------------
const transporter = nodemailer.createTransport({
  host: process.env.EMAIL_HOST,               // smtp-relay.brevo.com
  port: Number(process.env.EMAIL_PORT),       // 587
  secure: false,
  auth: {
    user: process.env.EMAIL_USER,             // Brevo login
    pass: process.env.EMAIL_PASS,             // Brevo SMTP key
  },
});

// Verify SMTP connection on server start
transporter.verify((error) => {
  if (error) {
    console.error("❌ SMTP connection failed:", error);
  } else {
    console.log("✅ Brevo SMTP connected successfully");
  }
});

// ------------------------
// SEND EMAIL OTP
// ------------------------
router.post("/send-verification-otp", async (req, res) => {
  try {
    const { email } = req.body;

    if (!email || !emailRegex.test(email)) {
      return res.status(400).json({ error: "Invalid email" });
    }

    const otp = Math.floor(100000 + Math.random() * 900000).toString();
    const otpExpiry = new Date(Date.now() + 5 * 60 * 1000); // 5 minutes

    let preUser = await PreUser.findOne({ email });

    // Prevent OTP spam
    if (preUser && preUser.otpExpiry && preUser.otpExpiry.getTime() > Date.now()) {
      return res.status(400).json({
        error: "OTP already sent. Please wait before requesting again.",
      });
    }

    if (!preUser) {
      preUser = new PreUser({
        email,
        otp,
        otpExpiry,
        isVerified: false,
      });
    } else {
      preUser.otp = otp;
      preUser.otpExpiry = otpExpiry;
      preUser.isVerified = false;
    }

    await preUser.save();

    await transporter.sendMail({
      from: `"Sahaya Support" <disasterrelief.sahaya@gmail.com>`, // must be verified sender
      to: email,
      subject: "Your Email Verification OTP",
      html: `
        <h3>Email Verification</h3>
        <p>Your OTP is <b>${otp}</b></p>
        <p>This OTP will expire in 5 minutes.</p>
      `,
    });

    res.json({ message: "OTP sent successfully" });
  } catch (err) {
    console.error("Send OTP error:", err);
    res.status(500).json({ error: "Failed to send OTP" });
  }
});

// ------------------------
// VERIFY EMAIL OTP
// ------------------------
router.post("/verify-email-otp", async (req, res) => {
  try {
    const { email, otp } = req.body;

    if (!email || !otp) {
      return res.status(400).json({ error: "Email and OTP required" });
    }

    const preUser = await PreUser.findOne({ email });
    if (!preUser) {
      return res.status(404).json({ error: "OTP not requested" });
    }

    if (!preUser.otpExpiry || preUser.otpExpiry.getTime() < Date.now()) {
      return res.status(400).json({ error: "OTP expired" });
    }
    const enteredOtp = String(otp).trim();
    const storedOtp = String(preUser.otp).trim();
    console.log("Stored OTP:", preUser.otp);
    console.log("Entered OTP:", otp);


    if (enteredOtp !== storedOtp) {
      return res.status(400).json({ error: "Invalid OTP" });
    }


    // Mark verified and invalidate OTP
    preUser.isVerified = true;
    preUser.otp = null;
    preUser.otpExpiry = null;
    await preUser.save();

    res.json({ message: "Email verified successfully" });
  } catch (err) {
    console.error("Verify OTP error:", err);
    res.status(500).json({ error: "OTP verification failed" });
  }
});

// ------------------------
// REGISTER USER
// ------------------------
router.post("/register", async (req, res) => {
  try {
    const {
      Name,
      gender,
      dob,
      mobile,
      email,
      address,
      houseNo,
      guardianName,
      guardianRelation,
      guardianMobile,
      guardianEmail,
      guardianAddress,
    } = req.body;

    // Check OTP verification
    const preUser = await PreUser.findOne({ email });
    if (!preUser || !preUser.isVerified) {
      return res.status(400).json({ error: "Email not verified" });
    }

    // Check existing user
    const existingUser = await User.findOne({ email });
    if (existingUser) {
      return res.status(400).json({ error: "User already exists" });
    }

    // Validate required fields
    if (
      !Name || !gender || !dob || !mobile || !email || !address ||
      !houseNo || !guardianName || !guardianRelation ||
      !guardianMobile || !guardianEmail || !guardianAddress
    ) {
      return res.status(400).json({ error: "All fields are required" });
    }

    if (!emailRegex.test(email) || !emailRegex.test(guardianEmail)) {
      return res.status(400).json({ error: "Invalid email format" });
    }

    if (!mobileRegex.test(mobile) || !mobileRegex.test(guardianMobile)) {
      return res.status(400).json({ error: "Invalid mobile number" });
    }

    // Generate password
    const randomPassword = Math.random().toString(36).slice(-8);
    const hashedPassword = await bcrypt.hash(randomPassword, 10);

    const newUser = new User({
      Name,
      gender,
      dob,
      mobile,
      email,
      password: hashedPassword,
      address,
      houseNo,
      guardianName,
      guardianRelation,
      guardianMobile,
      guardianEmail,
      guardianAddress,
      isEmailVerified: true,
    });

    await newUser.save();
    await PreUser.deleteOne({ email });

    await transporter.sendMail({
      from: `"Sahaya Support" <disasterrelief.sahaya@gmail.com>`,
      to: email,
      subject: "Your Sahaya Account Password",
      html: `
        <h3>Welcome, ${Name}</h3>
        <p>Your Sahaya account has been created successfully.</p>
        <p><b>Login Password:</b> ${randomPassword}</p>
        <p>Please keep this password safe.</p>
      `,
    });

    res.json({
      message: "User registered successfully. Password sent to email.",
    });
  } catch (err) {
    console.error("Register error:", err);
    res.status(500).json({ error: "Registration failed" });
  }
});

// ------------------------
// LOGIN USER
// ------------------------
router.post("/login", async (req, res) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({ error: "Email and password required" });
    }

    const user = await User.findOne({ email });
    if (!user) {
      return res.status(401).json({ error: "Invalid credentials" });
    }

    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.status(401).json({ error: "Invalid credentials" });
    }

    res.json({
      message: "Login successful",
      user: {
        _id: user._id,
        Name: user.Name,
        email: user.email,
        mobile: user.mobile,
      },
    });
  } catch (err) {
    console.error("Login error:", err);
    res.status(500).json({ error: "Login failed" });
  }
});

export default router;
