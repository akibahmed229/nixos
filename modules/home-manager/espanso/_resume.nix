{...}: [
  # --- 1. Dynamic Cover Letter ---
  # Pops up a form to fill in Company, Recruiter Name, and Job Title
  {
    trigger = "::cv";
    replace = ''
      Dear [recruiter],

      As a long-time admirer of [company]'s well-rounded student experience, I am excited to submit my application for the [role] position posted on [source]. I had the pleasure of speaking with [referral] at the Annual School Event, who suggested I contact you.

      To shortly introduce myself, my name is [myname]. I noticed the student diversity and [company]'s ability to speak the language of the community it serves. I am thrilled about the prospect to participate. I believe that my proficiency with Microsoft software tools, attention to detail and interpersonal skills will contribute to the daily clerical duties at [company].

      During my voluntary service at [volunteer_loc], I got praised for my ability to get along with people from different nationalities. Furthermore, I have gained functional/technical skills with web-based applications and Microsoft Office.

      While my attached resume provides an outline of my abilities, I would welcome the opportunity to further discuss how I can contribute to the day-to-day work at [company].

      You can reach me at [email] or [phone]. Thank you for your time and consideration.

      Sincerely,
      [myname]
    '';
  }

  # --- 2. Professional Summary (Short) ---
  {
    trigger = "::summary";
    replace = "Computer science graduate with 3+ years' experience in Full Stack Development. Dedicated to implementing scalable web solutions. As of {{date}}, I am available for full-time employment.";
    vars = [
      {
        name = "date";
        type = "date";
        params = {format = "%B %Y";};
      }
    ];
  }

  # --- 3. Interview Availability ---
  {
    trigger = "::avail";
    replace = "Thank you for reaching out. I am available for an interview on the following dates:\n- {{day1}}\n- {{day2}}\n\nPlease let me know if either of these works for you.";
    vars = [
      {
        name = "day1";
        type = "date";
        params = {
          format = "%A, %B %d at 10:00 AM EST";
          offset = 86400;
        };
      } # Tomorrow
      {
        name = "day2";
        type = "date";
        params = {
          format = "%A, %B %d at 2:00 PM EST";
          offset = 172800;
        };
      } # Day after tomorrow
    ];
  }
]
