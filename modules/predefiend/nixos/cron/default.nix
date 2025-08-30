{pkgs, ...}: {
  # Enable cron service
  # Note: *     *    *     *     *          command to run
  #      min  hour  day  month  year        user command
  cron = {
    enable = true;
    systemCronJobs = [
      ''* * * * * akib     echo "Hello World" >> /home/akib/hello.txt''
    ];
  };
}
