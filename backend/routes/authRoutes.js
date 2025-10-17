import express from "express";
import bcrypt from "bcryptjs";
import User from "../models/User.js";
import PreUser from "../models/preUser.js";
import nodemailer from "nodemailer";

const router = express.Router();

// Regex for validation
const emailRegex = /^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$/;
const mobileRegex = /^\d{10}$/;

// Nodemailer transporter
const transporter = nodemailer.createTransport({
  service: "gmail",
  auth: {
    user: process.env.EMAIL_USER,
    pass: process.env.EMAIL_PASS,
  },
});

// ------------------------
// Send OTP (Pre-registration)
// ------------------------
router.post("/send-verification-otp", async (req, res) => {
  try {
    const { email } = req.body;
    if (!emailRegex.test(email)) return res.status(400).json({ error: "Invalid email" });

    // Generate OTP
    const otp = Math.floor(100000 + Math.random() * 900000);
    const otpExpiry = new Date(Date.now() + 5 * 60 * 1000);

    // Save/update in PreUser
    let preUser = await PreUser.findOne({ email });
    if (!preUser) preUser = new PreUser({ email, otp, otpExpiry });
    else { preUser.otp = otp; preUser.otpExpiry = otpExpiry; preUser.isVerified = false; }

    await preUser.save();

    // Send email
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
    if (preUser.otpExpiry < Date.now()) return res.status(400).json({ error: "OTP expired" });
    if (String(preUser.otp) !== String(otp)) return res.status(400).json({ error: "Invalid OTP" });

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
      Name, gender, dob, mobile, email, password,
      address, houseNo, guardianName, guardianRelation,
      guardianMobile, guardianEmail, guardianAddress
    } = req.body;

    // Validate email verification
    //const preUser = await PreUser.findOne({ email });
    //if (!preUser || !preUser.isVerified)
      //return res.status(400).json({ error: "Email not verified" });

    // Check if user exists
    const existingUser = await User.findOne({ email });
    if (existingUser) return res.status(400).json({ error: "User already exists" });

    // Validate fields
    if (!Name || !gender || !dob || !mobile || !email || !password || !address || !houseNo || !guardianName || !guardianRelation || !guardianMobile || !guardianEmail || !guardianAddress)
      return res.status(400).json({ error: "All fields are required" });
    if (!emailRegex.test(email) || !emailRegex.test(guardianEmail)) return res.status(400).json({ error: "Invalid email format" });
    if (!mobileRegex.test(mobile) || !mobileRegex.test(guardianMobile)) return res.status(400).json({ error: "Invalid mobile number" });

    // Hash password
    const hashedPassword = await bcrypt.hash(password, 10);

    // Create user
    const newUser = new User({
      Name, gender, dob, mobile, email, password: hashedPassword,
      address, houseNo, guardianName, guardianRelation, guardianMobile, guardianEmail, guardianAddress,
      isEmailVerified: true
    });

    await newUser.save();
    await PreUser.deleteOne({ email }); // remove preUser record

    res.json({ message: "User registered successfully" });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: err.message });
  }
});

export default router;
