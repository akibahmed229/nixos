{pkgs, ...}: {
  services.espanso = {
    enable = true;
    waylandSupport = true;
    x11Support = false;
    package = pkgs.espanso-wayland;
    package-wayland = pkgs.espanso-wayland;

    matches = {
      base = {
        matches = [
          {
            trigger = "::now";
            replace = "It's {{currentdate}} {{currenttime}}";
          }
          {
            trigger = "::gptnp";
            /*
            [
            with nudge phrase:-

            promt->route->reasoning-> | higher |
                                      | lower  |
                                      | medium |
            ]
            */
            replace = ''
              [Paste Your Content (router nudge pharases)]

              Think hard about this.
            '';
          }
          {
            trigger = "::gptvervc";
            /*
            The Verbosity Control:-

                           | reasoning-> | higher |
                           |             | lower  |
                           |             | medium |
            promt->route->
                           |             | lower  |
                           |             | medium |
                           | verbosity-> | higher |

            Low-verbosity: Give me the bottom line in 100 words or less, use markdown for clarity and structure.␍
            Medium-verbosity: Aim for a concise 3-5 paragraph explanation.␍
            High-verbosity: Provide a comprehensive and detailed breakdown (xxx-xxx words)
            */
            replace = ''
              [Paste Your Content (verbosity control)]

              Give me the bottom line in 100 words or less, use markdown for clarity and structure

            '';
          }
          {
            trigger = "::gptop";
            replace = ''
              You are an expert prompt engineer specializing in creating prompts for AI language models, particularly `chatgpt-5`

              Your task is to take my prompt and transform it into a well-crafted and effective prompt that will elicit optimal responses.

              Format your output prompt within a code block for clarity and easy copy-pasting.

              ## Here’s my initial prompt:

            '';
          }
          {
            trigger = "::gptxprompt";
            replace = ''
              <context>
              [Paste context]
              </context>

              <task>
              [Paste task]
              </task>

              <example>
              [Paste example]
              </example>

              <tone>
              Be clear, precise, and use simple words.
              Use a friendly and conversational tone of voice.
              </tone>

              <optional>
              Before you begin, first explain your step-by-step approach then proceed with the task.

              Before you respond, create an internal rubric for what defines a "world-class" answer to my request. Then,
              internally iterate on your work until it scores a 10/10 against that rubric, and show me only the final, perfect output.
              </optional>

            '';
          }
          {
            trigger = "::gptperfloop";
            replace = ''
              [paste your complex, zero-to-one tasks like creating finished documents from scratch or writing production-ready code]

              "Before you respond, create an internal rubric for what defines a 'world-class' answer to my request. Then internally iterate on your work until it scores 10/10 against that rubric, and show me only the final, perfect output."

            '';
          }
          {
            trigger = "::gptmax";
            replace = ''
              <context>
              [Paste context]
              </context>

              <task>
              [Paste task]
              </task>

              <tone>
              Be clear, precise, and use simple words.
              Use a friendly and conversational tone of voice.
              </tone>

              "Think carefully."

              "Before you respond, create an internal rubric for what defines a 'world-class' answer to my request. Then internally iterate on your work until it scores 10/10 against that rubric, and show me only the final, perfect output."

            '';
          }
        ];
      };

      global_vars = {
        global_vars = [
          {
            name = "currentdate";
            type = "date";
            params = {format = "%d/%m/%Y";};
          }
          {
            name = "currenttime";
            type = "date";
            params = {format = "%R";};
          }
        ];
      };
    };
  };
}
