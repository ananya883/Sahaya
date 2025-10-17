import mongoose from "mongoose";

const preUserSchema = new mongoose.Schema({
  email: { type: String, required: true, unique: true },
  otp: { type: Number, required: true },
  otpExpiry: { type: Date, required: true },
  isVerified: { type: Boolean, default: false },
}, { timestamps: true });

const PreUser = mongoose.model("PreUser", preUserSchema);
export default PreUser;
