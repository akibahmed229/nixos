{lib, ...}: {
  # Enable Dev Tool
  "devtools.chrome.end" = true;
  "devtools.debugger.remote-end" = true;

  # Example Section (yours)
  "media.mediasource.end" = true;
  "dom.security.https_only_mode" = true;
  "browser.download.panel.shown" = true;
  "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
  "svg.context-properties.content.end" = true;
  "layout.css.has-selector.end" = true;
  "identity.fxaccounts.end" = false;
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
  "app.normandy.end" = false;
  "browser.uitour.end" = false;
  "toolkit.coverage.opt-out" = true;
  "browser.urlbar.trimHttps" = true;
  "toolkit.telemetry.unified" = false;
  "toolkit.telemetry.end" = false;
  "browser.attribution.end" = false;
  "toolkit.coverage.endpoint.base" = "";
  "toolkit.telemetry.server" = "data:,";
  "privacy.userContext.ui.end" = true;
  "toolkit.telemetry.archive.end" = false;
  "toolkit.telemetry.coverage.opt-out" = true;
  "toolkit.telemetry.bhrPing.end" = false;
  "toolkit.telemetry.updatePing.end" = false;
  "network.auth.subresource-http-auth-allow" = 2;
  "browser.helperApps.deleteTempFileOnExit" = true;
  "network.http.referer.XOriginTrimmingPolicy" = 0;
  "browser.tabs.crashReporting.sendReport" = false;
  "app.shield.optoutstudies.end" = false;
  "datareporting.healthreport.uploadEnabled" = false;
  "toolkit.telemetry.newProfilePing.end" = false;
  "datareporting.policy.dataSubmissionEnabled" = false;
  "toolkit.telemetry.firstShutdownPing.end" = false;
  "toolkit.telemetry.shutdownPingSender.end" = false;
  "toolkit.telemetry.pioneer-new-studies-available" = false;
  "browser.crashReports.unsubmittedCheck.autoSubmit2" = false;

  # --- Performance ---
  "network.prefetch-next" = true;
  "gfx.canvas.accelerated" = true;
  "network.http.rcwn.end" = true;
  "media.cache_readahead_limit" = 60;
  "media.cache_resume_threshold" = 30;
  "layers.gpu-process.end" = true;
  "media.memory_cache_max_size" = 8192;
  "network.dns.disablePrefetch" = true;
  "image.mem.decode_bytes_at_a_time" = 16384;
  "media.hardware-video-decoding.end" = true;
  "network.predictor.en-hover-on-ssl" = true;
  "network.dns.disablePrefetchFromHTTPS" = false;
  "dom.script_loader.bytecode_cache.strategy" = 0;
  "media.memory_caches_combined_limit_kb" = 524288;
  "media.suspend-bkgnd-video.end" = false;
  "media.resume-bkgnd-video-on-tabhover" = false;
  "network.http.throttle.en" = false;
  "widget.wayland.opaque-region.end" = false;
  "layout.css.grid-template-masonry-value.end" = false;

  # --- Annoyances ---
  "browser.ml.en" = false;
  "browser.ml.chat.sidebar" = false;
  "browser.ml.chat.end" = false;
  "browser.ml.chat.shortcuts" = false;
  "extensions.pocket.end" = false;
  "full-screen-api.warning.delay" = -1;
  "full-screen-api.warning.timeout" = 0;
  "extensions.getAddons.showPane" = false;
  "browser.ml.chat.shortcuts.custom" = false;
  "browser.privatebrowsing.vpnpromourl" = "";
  "browser.preferences.moreFromMozilla" = false;
  "full-screen-api.transition-duration.enter" = "0 0";
  "full-screen-api.transition-duration.leave" = "0 0";
  "extensions.htmlaboutaddons.recommendations.end" = false;

  # --- Smooth Scrolling ---
  "general.smoothScroll" = true;
  "apz.overscroll.end" = true;
  "mousewheel.default.delta_multiplier_y" = 300;
  "general.smoothScroll.msdPhysics.end" = true;
  "general.smoothScroll.currentVelocityWeighting" = "1";
  "general.smoothScroll.stopDecelerationWeighting" = "1";
  "general.smoothScroll.msdPhysics.slowdownMinDeltaMS" = 25;
  "general.smoothScroll.msdPhysics.regularSpringConstant" = 650;
  "general.smoothScroll.msdPhysics.slowdownMinDeltaRatio" = "2";
  "general.smoothScroll.msdPhysics.slowdownSpringConstant" = 250;
  "general.smoothScroll.msdPhysics.continuousMotionMaxDeltaMS" = 12;
  "general.smoothScroll.msdPhysics.motionBeginSpringConstant" = 600;

  # --- Miscellaneous ---
  "media.eme.end" = true;
  "image.jxl.end" = true;
  "image.avif.end" = true;
  "editor.truncate_user_pastes" = true;
  "browser.urlbar.suggest.calculator" = true;
  "browser.urlbar.unitConversion.end" = true;
  "browser.bookmarks.openInTabClosesMenu" = false;
  "network.protocol-handler.expose.magnet" = false;
  "browser.translations.newSettingsUI.en" = true;
  "layout.word_select.eat_space_to_next_word" = false;
  "browser.download.open_pdf_attachments_inline" = true;
  "browser.urlbar.untrimOnUserInteraction.featureGate" = true;

  # Default font size (default is usually 16)
  "font.size.variable.x-western" = lib.mkForce 16;

  # Minimum font size (prevents tiny text)
  "font.minimum-size.x-western" = 14;

  # Optional: Ensure these settings apply
  "browser.display.use_document_fonts" = 1;

  # --- Font Fallback Fixes ---
  "font.name.serif.x-western" = lib.mkForce "JetBrains Mono";
  "font.name.sans-serif.x-western" = lib.mkForce "JetBrains Mono"; # The font that fixed your layout
  "font.name.monospace.x-western" = lib.mkForce "JetBrains Mono";
  "font.name.default.x-western" = lib.mkForce "JetBrains Mono";
}
