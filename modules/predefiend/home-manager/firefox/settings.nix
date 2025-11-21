{lib, ...}: {
  # Enable Dev Tool
  "devtools.chrome.enabled" = true;
  "devtools.debugger.remote-enabled" = true;

  # Example Section (yours)
  "media.mediasource.enabled" = true;
  "dom.security.https_only_mode" = true;
  "browser.download.panel.shown" = true;
  "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
  "svg.context-properties.content.enabled" = true;
  "layout.css.has-selector.enabled" = true;
  "identity.fxaccounts.enabled" = false;
  "signon.rememberSignons" = false;

  # --- Theme Adjustments ---
  "sidebar.verticalTabs" = true;
  "sidebar.visibility" = "always-show";
  "sidebar.expandOnHover" = true;
  "browser.uidensity" = 1;
  "sidebar.revamp" = false;
  "widget.windows.mica.popups" = 0;
  "browser.compactmode.show" = true;
  "widget.non-native-theme.scrollbar.style" = 2;
  "gfx.font_rendering.cleartype_params.rendering_mode" = 5;
  "gfx.font_rendering.cleartype_params.cleartype_level" = 100;
  "gfx.font_rendering.directwrite.use_gdi_table_loading" = false;

  # --- Privacy ---
  "breakpad.reportURL" = "";
  "app.normandy.api_url" = "";
  "app.normandy.enabled" = false;
  "browser.uitour.enabled" = false;
  "toolkit.coverage.opt-out" = true;
  "browser.urlbar.trimHttps" = true;
  "toolkit.telemetry.unified" = false;
  "toolkit.telemetry.enabled" = false;
  "browser.attribution.enabled" = false;
  "toolkit.coverage.endpoint.base" = "";
  "toolkit.telemetry.server" = "data:,";
  "privacy.userContext.ui.enabled" = true;
  "toolkit.telemetry.archive.enabled" = false;
  "toolkit.telemetry.coverage.opt-out" = true;
  "toolkit.telemetry.bhrPing.enabled" = false;
  "toolkit.telemetry.updatePing.enabled" = false;
  "network.auth.subresource-http-auth-allow" = 2;
  "browser.helperApps.deleteTempFileOnExit" = true;
  "network.http.referer.XOriginTrimmingPolicy" = 0;
  "browser.tabs.crashReporting.sendReport" = false;
  "app.shield.optoutstudies.enabled" = false;
  "datareporting.healthreport.uploadEnabled" = false;
  "toolkit.telemetry.newProfilePing.enabled" = false;
  "datareporting.policy.dataSubmissionEnabled" = false;
  "toolkit.telemetry.firstShutdownPing.enabled" = false;
  "toolkit.telemetry.shutdownPingSender.enabled" = false;
  "toolkit.telemetry.pioneer-new-studies-available" = false;
  "browser.crashReports.unsubmittedCheck.autoSubmit2" = false;

  # --- Performance ---
  "network.prefetch-next" = true;
  "gfx.canvas.accelerated" = true;
  "network.http.rcwn.enabled" = true;
  "media.cache_readahead_limit" = 60;
  "media.cache_resume_threshold" = 30;
  "layers.gpu-process.enabled" = true;
  "media.memory_cache_max_size" = 8192;
  "network.dns.disablePrefetch" = true;
  "image.mem.decode_bytes_at_a_time" = 16384;
  "media.hardware-video-decoding.enabled" = true;
  "network.predictor.enable-hover-on-ssl" = true;
  "network.dns.disablePrefetchFromHTTPS" = false;
  "dom.script_loader.bytecode_cache.strategy" = 0;
  "media.memory_caches_combined_limit_kb" = 524288;
  "media.suspend-bkgnd-video.enabled" = false;
  "media.resume-bkgnd-video-on-tabhover" = false;
  "network.http.throttle.enable" = false;
  "widget.wayland.opaque-region.enabled" = false;
  "layout.css.grid-template-masonry-value.enabled" = false;

  # --- Annoyances ---
  "browser.ml.enable" = false;
  "browser.ml.chat.sidebar" = false;
  "browser.ml.chat.enabled" = false;
  "browser.ml.chat.shortcuts" = false;
  "extensions.pocket.enabled" = false;
  "full-screen-api.warning.delay" = -1;
  "full-screen-api.warning.timeout" = 0;
  "extensions.getAddons.showPane" = false;
  "browser.ml.chat.shortcuts.custom" = false;
  "browser.privatebrowsing.vpnpromourl" = "";
  "browser.preferences.moreFromMozilla" = false;
  "full-screen-api.transition-duration.enter" = "0 0";
  "full-screen-api.transition-duration.leave" = "0 0";
  "extensions.htmlaboutaddons.recommendations.enabled" = false;

  # --- Smooth Scrolling ---
  "general.smoothScroll" = true;
  "apz.overscroll.enabled" = true;
  "mousewheel.default.delta_multiplier_y" = 300;
  "general.smoothScroll.msdPhysics.enabled" = true;
  "general.smoothScroll.currentVelocityWeighting" = "1";
  "general.smoothScroll.stopDecelerationWeighting" = "1";
  "general.smoothScroll.msdPhysics.slowdownMinDeltaMS" = 25;
  "general.smoothScroll.msdPhysics.regularSpringConstant" = 650;
  "general.smoothScroll.msdPhysics.slowdownMinDeltaRatio" = "2";
  "general.smoothScroll.msdPhysics.slowdownSpringConstant" = 250;
  "general.smoothScroll.msdPhysics.continuousMotionMaxDeltaMS" = 12;
  "general.smoothScroll.msdPhysics.motionBeginSpringConstant" = 600;

  # --- Miscellaneous ---
  "media.eme.enabled" = true;
  "image.jxl.enabled" = true;
  "image.avif.enabled" = true;
  "editor.truncate_user_pastes" = true;
  "browser.urlbar.suggest.calculator" = true;
  "browser.urlbar.unitConversion.enabled" = true;
  "browser.bookmarks.openInTabClosesMenu" = false;
  "network.protocol-handler.expose.magnet" = false;
  "browser.translations.newSettingsUI.enable" = true;
  "layout.word_select.eat_space_to_next_word" = false;
  "browser.download.open_pdf_attachments_inline" = true;
  "browser.urlbar.untrimOnUserInteraction.featureGate" = true;

  # Default font size (default is usually 16)
  "font.size.variable.x-western" = lib.mkDefault 20;

  # Minimum font size (prevents tiny text)
  "font.minimum-size.x-western" = 14;

  # Optional: Ensure these settings apply
  "browser.display.use_document_fonts" = 1;
}
