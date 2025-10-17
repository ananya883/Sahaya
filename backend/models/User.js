import mongoose from "mongoose";

const userSchema = new mongoose.Schema(
  {
    // User Details
   Name: { type: String, required: true },
    gender: { type: String, required: true },
    dob: { type: String, required: true }, // Can also use Date type if preferred
    mobile: { type: String, required: true },
    email: { type: String, required: true, unique: true },
    password: { type: String, required: true },
    address: { type: String, required: true },
    houseNo: { type: String, required: true },

    // Guardian Details
    guardianName: { type: String, required: true },
    guardianRelation: { type: String, required: true },
    guardianMobile: { type: String, required: true },
    guardianEmail: { type: String, required: true },
    guardianAddress: { type: String, required: true },
   isEmailVerified: { type: Boolean, default: false },
  emailOtp: { type: String },
  emailOtpExpires: { type: Date },
   
    otp: { type: String },
    otpExpires: { type: Date },
  },
  { timestamps: true } // Automatically adds createdAt and updatedAt
);

export default mongoose.model("User", userSchema);
