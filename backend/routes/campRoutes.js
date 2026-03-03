import express from "express";
import Camp from "../models/Camp.js";

const router = express.Router();

// GET /api/camps - Fetch all camps with location data
router.get("/", async (req, res) => {
    try {
        const camps = await Camp.find({ status: "active" });
        res.status(200).json(camps);
    } catch (err) {
        console.error("❌ Camp Fetch Error:", err);
        res.status(500).json({ message: "Failed to fetch camps", error: err.message });
    }
});

export default router;
