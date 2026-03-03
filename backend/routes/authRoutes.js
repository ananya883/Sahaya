import dotenv from "dotenv";
dotenv.config();

import express from "express";
import bcrypt from "bcryptjs";
import nodemailer from "nodemailer";
import User from "../models/User.js";
import PreUser from "../models/preUser.js";

import path from "path";
import multer from "multer";
import fs from "fs";
import { fileURLToPath } from "url";

const router = express.Router();

// ------------------------
// Multer Configuration
// ------------------------
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Ensure uploads directory exists
const uploadDir = path.join(__dirname, "../uploads");
if (!fs.existsSync(uploadDir)) {
  fs.mkdirSync(uploadDir, { recursive: true });
}

const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, uploadDir);
  },
  filename: (req, file, cb) => {
    cb(null, Date.now() + "-" + file.originalname);
  },
});

const upload = multer({ storage });

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
// ------------------------
// REGISTER USER
// ------------------------
router.post(
  "/register",
  upload.fields([
    { name: "govtId", maxCount: 1 },
    { name: "certificate", maxCount: 1 },
  ]),
  async (req, res) => {
    console.log("👉 [REGISTER] Request received");
    try {
      // Parse body (handled by multer, fields are in req.body)
      const {
        Name,
        gender,
        dob,
        mobile,
        email,
        address,
        houseNo,
        // Guardian fields (optional for volunteers)
        guardianName,
        guardianRelation,
        guardianMobile,
        guardianEmail,
        guardianAddress,
        // Role & Volunteer fields
        role, // "user" or "volunteer"
        password, // Manual password for volunteers
        skills,
        trainingAttended,
        serviceLocation,
      } = req.body;

      console.log(`👉 [REGISTER] Payload: Name=${Name}, Email=${email}, Role=${role}`);

      const userRole = role || "user";

      // Check OTP verification (Optional: You might want to skip this for volunteers if they don't do OTP flow first? 
      // Assuming they DO email verification first just like users)
      const preUser = await PreUser.findOne({ email });
      if (!preUser || !preUser.isVerified) {
        console.log("❌ [REGISTER] Email not verified");
        return res.status(400).json({ error: "Email not verified" });
      }

      // Check existing user
      const existingUser = await User.findOne({ email });
      if (existingUser) {
        console.log("❌ [REGISTER] User already exists");
        return res.status(400).json({ error: "User already exists" });
      }

      // --- Validation ---
      // Common fields
      if (
        !Name ||
        !gender ||
        !dob ||
        !mobile ||
        !email ||
        !address ||
        !houseNo
      ) {
        console.log("❌ [REGISTER] Missing basic fields");
        return res.status(400).json({ error: "Basic fields are required" });
      }

      // Guardian fields required ONLY if role === 'user'
      if (userRole === "user") {
        if (
          !guardianName ||
          !guardianRelation ||
          !guardianMobile ||
          !guardianEmail ||
          !guardianAddress
        ) {
          console.log("❌ [REGISTER] Missing guardian fields for user");
          return res.status(400).json({ error: "Guardian fields are required for users" });
        }
      }

      if (!emailRegex.test(email)) {
        return res.status(400).json({ error: "Invalid email format" });
      }
      if (!mobileRegex.test(mobile)) {
        return res.status(400).json({ error: "Invalid mobile number" });
      }

      // --- Password Handling ---
      let finalPassword = "";
      let isManualPassword = false;

      if (password && password.trim().length > 0) {
        // Use provided password (e.g. for volunteers)
        finalPassword = password;
        isManualPassword = true;
      } else {
        // Generate random password (legacy flow)
        finalPassword = Math.random().toString(36).slice(-8);
      }

      const hashedPassword = await bcrypt.hash(finalPassword, 10);

      // --- File Uploads (Volunteer) ---
      let govtIdPath = "";
      let certificatesPath = "";

      if (req.files) {
        console.log("👉 [REGISTER] Processing files...");
        if (req.files.govtId) govtIdPath = req.files.govtId[0].path;
        if (req.files.certificate) certificatesPath = req.files.certificate[0].path;
      }

      // --- Create User ---
      const newUser = new User({
        Name,
        gender,
        dob,
        mobile,
        email,
        password: hashedPassword,
        address,
        houseNo,
        role: userRole,

        // Guardian info (might be undefined if volunteer, which is fine now)
        guardianName,
        guardianRelation,
        guardianMobile,
        guardianEmail,
        guardianAddress,

        // Volunteer info
        volunteerDetails: {
          skills: skills ? skills.split(",") : [], // If sent as comma-separated string
          trainingAttended: trainingAttended === "true" || trainingAttended === true,
          serviceLocation,
          govtIdPath,
          certificatesPath,
        },

        isEmailVerified: true,
      });

      console.log("👉 [REGISTER] Saving user to DB...");
      await newUser.save();
      console.log("✅ [REGISTER] User saved to DB");

      await PreUser.deleteOne({ email });

      // Send email
      console.log("👉 [REGISTER] Attempting to send email...");
      try {
        if (isManualPassword) {
          // Just welcome email
          await transporter.sendMail({
            from: `"Sahaya Support" <disasterrelief.sahaya@gmail.com>`,
            to: email,
            subject: "Welcome to Sahaya",
            html: `
              <h3>Welcome, ${Name}</h3>
              <p>Your Sahaya volunteer account has been created successfully.</p>
              <p>You can now login with your chosen password.</p>
            `,
          });
          console.log("✅ [REGISTER] Welcome email sent");
          res.json({ message: "Volunteer registered successfully." });
        } else {
          // Send generated password
          await transporter.sendMail({
            from: `"Sahaya Support" <disasterrelief.sahaya@gmail.com>`,
            to: email,
            subject: "Your Sahaya Account Password",
            html: `
                <h3>Welcome, ${Name}</h3>
                <p>Your Sahaya account has been created successfully.</p>
                <p><b>Login Password:</b> ${finalPassword}</p>
                <p>Please keep this password safe.</p>
              `,
          });
          console.log("✅ [REGISTER] Password email sent");
          res.json({
            message: "User registered successfully. Password sent to email.",
          });
        }
      } catch (emailErr) {
        console.error("⚠️ [REGISTER] Email sending failed but user registered:", emailErr);
        // Still return success because user IS registered
        res.json({ message: "User registered successfully (Email could not be sent)." });
      }

    } catch (err) {
      console.error("❌ [REGISTER] Register error:", err);
      res.status(500).json({ error: "Registration failed" });
    }
  }
);

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
        role: user.role || "user", // valid roles: 'user', 'volunteer'
      },
    });
  } catch (err) {
    console.error("Login error:", err);
    res.status(500).json({ error: "Login failed" });
  }
});

export default router;
