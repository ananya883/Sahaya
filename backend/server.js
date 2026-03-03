import express from "express";
import mongoose from "mongoose";
import cors from "cors";
import dotenv from "dotenv";
import path from "path";
import { fileURLToPath } from "url";

import authRoutes from "./routes/authRoutes.js";
import sosRoutes from "./routes/sosRoutes.js";
import missingPersonRoutes from "./routes/missingPersonRoutes.js";
import matchRoutes from "./routes/match.routes.js";              // ✅ ADD
import notificationRoutes from "./routes/notification.routes.js"; // ✅ ADD
import unknownRoutes from "./routes/unknown.routes.js";
import campRoutes from "./routes/campRoutes.js";                  // ✅ ADD

dotenv.config();

const app = express();

// ---------- Middleware ----------
app.use(cors());
app.use(express.json());

// Global Request Logger
app.use((req, res, next) => {
  console.log(`🔔 [INCOMING] ${req.method} ${req.url}`);
  next();
});

app.use("/api/unknown", unknownRoutes);


// ---------- File path setup ----------
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// ---------- Serve uploaded images ----------
app.use("/uploads", express.static(path.join(__dirname, "uploads")));

// ---------- Test route ----------
app.get("/", (req, res) => {
  res.send("Server is running!");
});

// ---------- Routes ----------
app.use("/api/auth", authRoutes);
app.use("/api/sos", sosRoutes);

// Missing person (register, list, etc.)
app.use("/api/missing", missingPersonRoutes);

// Matching (found person → AI → match)
app.use("/api/match", matchRoutes);                 // ✅ ADD

// Notifications
app.use("/api/notifications", notificationRoutes); // ✅ ADD

// Camps
app.use("/api/camps", campRoutes);                 // ✅ ADD

// ---------- DB & Server ----------
const PORT = process.env.PORT || 5001;

mongoose
  .connect(process.env.MONGO_URI)
  .then(() => {
    console.log("✅ MongoDB connected");
    app.listen(PORT, "0.0.0.0", () => {
      console.log(`🚀 Server running on port ${PORT}`);
    });
  })
  .catch((err) => {
    console.error("❌ MongoDB connection error:", err.message);
  });
