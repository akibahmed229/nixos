{...}: [
  # --- 1. Scheduling a Meeting ---
  {
    trigger = "::meet";
    replace = "Hi [name],\n\nWould you be free for a quick call to discuss [topic]? I'm free at [time]. Let me know what works best for you.";
  }

  # --- 2. Sending an Attachment (Safety Net) ---
  {
    trigger = "::attach";
    replace = "Please find the attached [file] for your review. Let me know if you have any questions.";
  }

  # --- 3. Polite Decline ---
  {
    trigger = "::no";
    replace = "Hi [name],\n\nThank you for thinking of me for this. Unfortunately, I don't have the bandwidth to take this on right now due to current project priorities.\n\nBest,\nAkib";
  }

  # --- 4. Generic Signature ---
  {
    trigger = "::sig";
    replace = ''
      Best regards,
      Akib
      Full Stack Developer | https://mywebsite.com
    '';
  }
]
