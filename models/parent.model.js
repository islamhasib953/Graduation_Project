const ParentSchema = new mongoose.Schema(
  {
    name: { type: String, required: [true, "Name is required"], trim: true },
    relationships: {
      type: String,
      enum: ["Father", "Mother", "Guardian"],
      required: [true, "Relationship is required"],
    },
    phone: {
      type: String,
      required: [true, "Phone number is required"],
      match: [/^\+?[0-9]{10,15}$/, "Invalid phone number"],
    },
    childId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Child",
      required: true,
    },
  },
  { timestamps: true }
);

module.exports = mongoose.model("Parent", ParentSchema);
