// Connector for the `below-site-header` plugin outlet — the global
// dismissable announcement banner (.sktvd-banner).
//
// It lives in below-site-header (full-width, above #main-outlet-wrapper) so it
// spans the whole screen above the sidebar, matching the mockup order:
//   header → nav → banner → [sidebar | content].
// The numeric prefix (sktvd-2-…) sorts it after the sktvd-1-nav connector.
//
// Written as a .gjs glimmer component so the dismiss button works (the old
// .hbs + (action) connector API is deprecated and its handlers were dead).

import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import { on } from "@ember/modifier";
import { htmlSafe } from "@ember/template";
import icon from "discourse/helpers/d-icon";

const STORAGE_KEY = "sktvd_banner_dismissed";

export default class SktvdBanner extends Component {
  @tracked dismissed = this.#storedDismissed();

  #storedDismissed() {
    try {
      return localStorage.getItem(STORAGE_KEY) === "1";
    } catch (e) {
      return false;
    }
  }

  get visible() {
    return settings.enable_admin_banner && !this.dismissed;
  }

  get bannerText() {
    return htmlSafe(settings.admin_banner_text || "");
  }

  get ctaUrl() {
    return settings.admin_banner_cta_url;
  }

  get ctaText() {
    return settings.admin_banner_cta_text;
  }

  @action
  dismiss() {
    try {
      localStorage.setItem(STORAGE_KEY, "1");
    } catch (e) {
      // localStorage unavailable — hide for this page view only
    }
    this.dismissed = true;
  }

  <template>
    {{#if this.visible}}
      <div class="sktvd-banner">
        <div class="sktvd-banner-inner">
          <span class="sktvd-banner-pill">Клуб</span>
          <div class="sktvd-banner-text">{{this.bannerText}}</div>
          {{#if this.ctaUrl}}
            <a href={{this.ctaUrl}} class="sktvd-banner-cta">{{this.ctaText}}</a>
          {{/if}}
          <button
            type="button"
            class="sktvd-banner-close"
            title="Скрыть"
            {{on "click" this.dismiss}}
          >
            {{icon "xmark"}}
          </button>
        </div>
      </div>
    {{/if}}
  </template>
}
