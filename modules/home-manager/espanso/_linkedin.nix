{...}: [
  # --- 1. Connection Request Note ---
  {
    trigger = "::liconnect";
    replace = "Hi [name], I came across your profile while researching [topic] and was impressed by your work at [company]. I'd love to connect and keep up with your updates!";
  }

  # --- 2. Reply to Recruiter (Interested) ---
  {
    trigger = "::liyes";
    replace = "Hi [name], thanks for reaching out! This role at [company] sounds very interesting and aligns well with my experience in [skill]. I'd be happy to hop on a call to discuss further.";
  }

  # --- 3. Reply to Recruiter (Not Interested) ---
  {
    trigger = "::lino";
    replace = "Hi [name], thank you for reaching out. Although this opportunity sounds great, I'm not currently looking for a new role. I will definitely keep [company] in mind for the future, though. Let's stay connected!";
  }

  # --- 4. Hashtag Block for Posts ---
  {
    trigger = "::tags";
    replace = "#softwareengineering #webdevelopment #nixos #coding #tech";
  }
]
