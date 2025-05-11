const mongoose = require("mongoose");

const chatSchema = new mongoose.Schema(
  {
    doctorId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Doctor",
      required: true,
    },
    childId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Child",
      required: true,
    },
    messages: [
      {
        sender: {
          type: String,
          required: true,
        },
        content: {
          type: String,
          required: false,
        },
        media: {
          type: String,
          default: null,
          validate: {
            validator: function (value) {
              if (value)
                return /\.(jpg|jpeg|png|gif|pdf|doc|docx)$/i.test(value);
              return true;
            },
            message: "Media must be a valid file (image, pdf, doc, docx)",
          },
        },
        timestamp: {
          type: Date,
          default: Date.now,
        },
      },
    ],
    createdAt: {
      type: Date,
      default: Date.now,
    },
  },
  { timestamps: true }
);

module.exports = mongoose.model("Chat", chatSchema);
