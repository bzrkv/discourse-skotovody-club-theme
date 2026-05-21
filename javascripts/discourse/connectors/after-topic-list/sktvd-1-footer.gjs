// Connector for the `after-topic-list` plugin outlet — block E5 of
// HOMEPAGE_SPEC: the member-only footer under the topic list.
//
//   E5a — "Показано N тем": a quiet count of the rendered rows.
//   E5b — "В Клубе": a stat strip with real figures from /about.json
//         (registered users / topics / posts). The spec also drew an
//         "online" figure + avatar stack, dropped here — Discourse has no
//         reliable "online now" source without the whos-online plugin
//         (review decision 2026-05-21).
//
// `after-topic-list` also fires on search / user pages, so the component
// is gated to discovery routes (homepage + categories) as well as members.

import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { service } from "@ember/service";
import { ajax } from "discourse/lib/ajax";

// Russian plural — picks the word form for a count: 1 тема / 2 темы / 5 тем.
function plural(n, forms) {
  const mod10 = n % 10;
  const mod100 = n % 100;
  if (mod10 === 1 && mod100 !== 11) {
    return forms[0];
  }
  if (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)) {
    return forms[1];
  }
  return forms[2];
}

// Space-grouped thousands, ru-RU style: 68920 → "68 920".
const fmt = (n) => Number(n).toLocaleString("ru-RU");

export default class SktvdListFooter extends Component {
  @service currentUser;
  @service router;

  @tracked shownCount = 0;
  @tracked stats = null;

  constructor() {
    super(...arguments);
    if (!this.enabled) {
      return;
    }
    this.#loadStats();
    // eslint-disable-next-line no-console
    {
      const oa = this.args.outletArgs || {};
      const desc = Object.keys(oa).map((k) => {
        const v = oa[k];
        const t = Array.isArray(v) ? `array[${v.length}]` : (v && v.length !== undefined ? `len=${v.length}` : typeof v);
        return `${k}:${t}`;
      }).join(" | ");
      console.log("[sktvd-e5] KEYS=" + desc);
    }
    // Defer one frame so the topic-list rows are in the DOM to be counted.
    requestAnimationFrame(() => this.#trackRows());
  }

  willDestroy() {
    super.willDestroy(...arguments);
    this._observer?.disconnect();
  }

  get enabled() {
    return (
      Boolean(this.currentUser) &&
      Boolean(this.router.currentRouteName?.startsWith("discovery."))
    );
  }

  async #loadStats() {
    try {
      const data = await ajax("/about.json");
      this.stats = data.about?.stats ?? null;
    } catch {
      // On failure leave stats null — the strip drops out rather than guess.
      this.stats = null;
    }
  }

  // Counts the rendered topic rows and keeps the figure fresh when infinite
  // scroll appends more.
  #trackRows() {
    const recount = () => {
      this.shownCount = document.querySelectorAll(".topic-list-item").length;
    };
    recount();
    const body = document.querySelector(".topic-list-body");
    if (body) {
      this._observer = new MutationObserver(recount);
      this._observer.observe(body, { childList: true });
    }
  }

  get shownLabel() {
    const n = this.shownCount;
    return `Показано ${fmt(n)} ${plural(n, ["тема", "темы", "тем"])}`;
  }

  get statsLine() {
    const s = this.stats;
    if (!s) {
      return null;
    }
    return [
      `${fmt(s.users_count)} ${plural(s.users_count, ["участник", "участника", "участников"])}`,
      `${fmt(s.topics_count)} ${plural(s.topics_count, ["тема", "темы", "тем"])}`,
      `${fmt(s.posts_count)} ${plural(s.posts_count, ["сообщение", "сообщения", "сообщений"])}`,
    ].join(" · ");
  }

  <template>
    {{#if this.enabled}}
      <div class="sktvd-list-footer">
        <span class="sktvd-list-footer-count">{{this.shownLabel}}</span>
      </div>

      {{#if this.statsLine}}
        <div class="sktvd-club-stats">
          <span class="sktvd-club-stats-label">В Клубе:</span>
          {{this.statsLine}}
        </div>
      {{/if}}
    {{/if}}
  </template>
}
