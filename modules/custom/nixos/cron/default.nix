# Configures the system-wide cron job scheduler.
{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.nm.cron;
in {
  # --- 1. Define Options ---
  options.nm.cron = {
    enable = mkEnableOption "Enable and configure the system cron service.";

    systemCronJobs = mkOption {
      type = types.listOf types.str;
      default = [];
      description = ''
        A list of system-wide cron jobs defined as raw strings.
        Format: "min hour day month weekday user command"
        Example: "* * * * * root /bin/echo 'system heartbeat' >> /var/log/cron.log"
      '';
    };

    userCronJobs = mkOption {
      type = types.listOf (types.submodule ({...}: {
        options = {
          user = mkOption {
            type = types.str;
            description = "The user who will execute the job.";
          };
          schedule = mkOption {
            type = types.str;
            description = "The cron schedule (min hour day month weekday).";
            example = "* * * * *";
          };
          command = mkOption {
            type = types.str;
            description = "The command to execute.";
          };
        };
      }));
      default = [];
      description = "A list of structured user-specific cron job definitions.";
    };
  };

  /*
  # Example usage
  ```nix
    nm.cron = {
      enable = true;

      # 1. Using the classic raw string format (retains your original job)
      systemCronJobs = [
        ''* * * * * akib echo "Hello World" >> /home/akib/hello.txt''
        ''0 1 * * * root /usr/bin/nix-collect-garbage -d''
      ];

      # 2. Using the more robust, structured format
      userCronJobs = [
        {
          user = "akib";
          schedule = "30 2 * * *";
          command = "${pkgs.git}/bin/git pull --rebase";
        }
        {
          user = "john";
          schedule = "@daily"; # cron supports special strings like @daily, @hourly, etc.
          command = "/home/john/scripts/backup.sh";
        }
      ];
    };
  ```
  */

  # --- 2. Define Configuration ---
  config = mkIf cfg.enable {
    # Enable the main cron service
    cron.enable = true;

    # Merge system-wide cron jobs defined as raw strings
    # Map the structured userCronJobs option to the cron.systemCronJobs format
    # This automatically formats the structured user data into the required string format.
    cron.systemCronJobs =
      cfg.systemCronJobs
      ++ lib.optionals (cfg.userCronJobs != []) (
        map (job: "${job.schedule} ${job.user} ${job.command}") cfg.userCronJobs
      );
  };
}
