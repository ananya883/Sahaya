import express from "express";
import Notification from "../models/Notification.js";

const router = express.Router();

// -----------------------------
// Get notifications for a user
// -----------------------------
router.get("/:userId", async (req, res) => {
  try {
    const notifications = await Notification.find({
      userId: req.params.userId,
    }).sort({ createdAt: -1 });

    res.json(notifications);
  } catch (err) {
    console.error("❌ Fetch notifications error:", err);
    res.status(500).json({ error: err.message });
  }
});

// -----------------------------
// Mark notification as read
// -----------------------------
router.post("/mark-read/:id", async (req, res) => {
  try {
    const notification = await Notification.findByIdAndUpdate(
      req.params.id,
      { isRead: true },
      { new: true }
    );

    if (!notification) {
      return res.status(404).json({ message: "Notification not found" });
    }

    res.json({ message: "Notification marked as read" });
  } catch (err) {
    console.error("❌ Mark-read error:", err);
    res.status(500).json({ error: err.message });
  }
});

export default router;
