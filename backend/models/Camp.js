import mongoose from "mongoose";

const campSchema = new mongoose.Schema({
    name: { type: String, required: true },
    location: { type: String },
    latitude: { type: Number, required: true },
    longitude: { type: Number, required: true },
    capacity: { type: Number },
    status: { type: String, default: "active" },
    createdAt: { type: Date, default: Date.now },
});

export default mongoose.model("Camp", campSchema);
