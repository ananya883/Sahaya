import dotenv from "dotenv";
dotenv.config();
import express from "express";
import bcrypt from "bcryptjs";
import User from "../models/User.js";
import PreUser from "../models/preUser.js";
import nodemailer from "nodemailer";

const router = express.Router();

// ------------------------
// Validation Regex
// ------------------------
const emailRegex = /^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$/;
const mobileRegex = /^\d{10}$/;

// ------------------------
// Nodemailer transporter
// ------------------------
const transporter = nodemailer.createTransport({
  service: "gmail",
  auth: {
    user: process.env.EMAIL_USER,
    pass: process.env.EMAIL_PASS,
  },
});

// ------------------------
// Send Verification OTP
// ------------------------
router.post("/send-verification-otp", async (req, res) => {
  try {
    const { email } = req.body;
    if (!email || !emailRegex.test(email))
      return res.status(400).json({ error: "Invalid email" });

    const otp = Math.floor(100000 + Math.random() * 900000);
    const otpExpiry = new Date(Date.now() + 5 * 60 * 1000);

    let preUser = await PreUser.findOne({ email });
    if (!preUser) preUser = new PreUser({ email, otp, otpExpiry });
    else {
      preUser.otp = otp;
      preUser.otpExpiry = otpExpiry;
      preUser.isVerified = false;
    }

    await preUser.save();

    await transporter.sendMail({
      from: process.env.EMAIL_USER,
      to: email,
      subject: "Your Email Verification OTP",
      html: `<h4>Hello,</h4><p>Your OTP is <b>${otp}</b>. It will expire in 5 minutes.</p>`,
    });

    res.json({ message: "OTP sent successfully" });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Failed to send OTP" });
  }
});

// ------------------------
// Verify Email OTP
// ------------------------
router.post("/verify-email-otp", async (req, res) => {
  try {
    const { email, otp } = req.body;
    const preUser = await PreUser.findOne({ email });
    if (!preUser) return res.status(404).json({ error: "OTP not requested" });
    if (preUser.otpExpiry < Date.now())
      return res.status(400).json({ error: "OTP expired" });
    if (String(preUser.otp) !== String(otp))
      return res.status(400).json({ error: "Invalid OTP" });

    preUser.isVerified = true;
    await preUser.save();

    res.json({ message: "Email verified successfully" });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: err.message });
  }
});

// ------------------------
// Register User
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

    // Check pre-verification
    const preUser = await PreUser.findOne({ email });
    if (!preUser || !preUser.isVerified)
      return res.status(400).json({ error: "Email not verified" });

    // Check existing user
    const existingUser = await User.findOne({ email });
    if (existingUser)
      return res.status(400).json({ error: "User already exists" });

    // Validate fields
    if (
      !Name ||
      !gender ||
      !dob ||
      !mobile ||
      !email ||
      !address ||
      !houseNo ||
      !guardianName ||
      !guardianRelation ||
      !guardianMobile ||
      !guardianEmail ||
      !guardianAddress
    )
      return res.status(400).json({ error: "All fields are required" });
    if (!emailRegex.test(email) || !emailRegex.test(guardianEmail))
      return res.status(400).json({ error: "Invalid email format" });
    if (!mobileRegex.test(mobile) || !mobileRegex.test(guardianMobile))
      return res.status(400).json({ error: "Invalid mobile number" });

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
      from: process.env.EMAIL_USER,
      to: email,
      subject: "Your Sahaya Account Password",
      html: `<h4>Welcome, ${Name}!</h4>
             <p>Your Sahaya account has been successfully created.</p>
             <p><b>Your login password:</b> ${randomPassword}</p>
             <p>Use this password to log in.</p>`,
    });

    res.json({ message: "User registered successfully. Password sent to email." });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: err.message });
  }
});

// ------------------------
// Login User
// ------------------------
router.post("/login", async (req, res) => {
  try {
    const { email, password } = req.body;
    if (!email || !password)
      return res.status(400).json({ error: "Email and password required" });

    const user = await User.findOne({ email });
    if (!user) return res.status(401).json({ error: "Invalid credentials" });

    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) return res.status(401).json({ error: "Invalid credentials" });

    res.status(200).json({ message: "Login successful" });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: err.message });
  }
});

// ------------------------
// Forgot Password
// ------------------------
router.post("/forgot-password", async (req, res) => {
  try {
    const { email } = req.body;
    const user = await User.findOne({ email });
    if (!user) return res.status(404).json({ error: "User not found" });

    // You can implement password reset email here
    res.json({ message: "Forgot password endpoint hit" });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: err.message });
  }
});

// ------------------------
// Test Email Endpoint
// ------------------------
router.get("/test-email", async (req, res) => {
  try {
    await transporter.sendMail({
      from: process.env.EMAIL_USER,
      to: process.env.EMAIL_USER,
      subject: "Test Email from Sahaya Backend",
      html: "<h3>✅ This is a test email from your Node.js backend!</h3>",
    });

    res.status(200).json({ message: "Test email sent successfully!" });
  } catch (err) {
    console.error("Test email error:", err);
    res.status(500).json({ message: "Failed to send test email", error: err.message });
  }
});

export default router;
