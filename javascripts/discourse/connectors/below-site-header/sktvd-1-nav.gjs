// Connector for the `below-site-header` plugin outlet — the full-width
// discovery navigation strip (HOMEPAGE_SPEC §3.B2 — the mockup's dc-viewnav).
//
// WHY here: Discourse's native discovery nav lives inside #main-outlet, right
// of the sidebar, so it can never be full-width. `below-site-header` renders
// between the site header and #main-outlet-wrapper — full-width. The native
// .list-controls nav is CSS-hidden.
//
// Tabs (spec order): Свежие · Новые [count] · Непрочитанные [count] · Лучшие ·
// Категории · Теги · Закладки. Right side: Фильтры (ghost) + Создать тему.

import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import { service } from "@ember/service";
import { on } from "@ember/modifier";
import { concat } from "@ember/helper";
import { htmlSafe } from "@ember/template";
import icon from "discourse/helpers/d-icon";

export default class SktvdNav extends Component {
  @service router;
  @service site;
  @service currentUser;
  @service topicTrackingState;
  @tracked filtersOpen = false;

  get onDiscovery() {
    const r = this.router.currentRouteName || "";
    return (
      r.startsWith("discovery") || r.startsWith("tags") || r.startsWith("tag.")
    );
  }

  #count(method) {
    try {
      const n = this.topicTrackingState?.[method]?.();
      return typeof n === "number" && n > 0 ? n : null;
    } catch (e) {
      return null;
    }
  }

  get tabs() {
    const url = (this.router.currentURL || "/").split("?")[0];
    const member = !!this.currentUser;
    const defs = [
      { label: "Свежие", href: "/latest", match: ["/", "/latest"] },
      member && {
        label: "Новые",
        href: "/new",
        match: ["/new"],
        count: this.#count("countNew"),
      },
      member && {
        label: "Непрочитанные",
        href: "/unread",
        match: ["/unread"],
        count: this.#count("countUnread"),
      },
      { label: "Лучшие", href: "/top", match: ["/top"] },
      { label: "Категории", href: "/categories", match: ["/categories"] },
      { label: "Теги", href: "/tags", match: ["/tags", "/tag"] },
      member && {
        label: "Закладки",
        href: "/bookmarks",
        match: ["/bookmarks"],
        icon: "bookmark",
      },
    ].filter(Boolean);

    return defs.map((t) => ({
      label: t.label,
      href: t.href,
      count: t.count,
      icon: t.icon,
      active: t.match.some(
        (m) => url === m || (m !== "/" && url.startsWith(m + "/"))
      ),
    }));
  }

  get categories() {
    return (this.site.categories || []).filter(
      (c) => !c.parent_category_id && !c.isUncategorizedCategory
    );
  }

  closeOnOutside = (event) => {
    if (!event.target.closest(".sktvd-nav-filters")) {
      this.#setFilters(false);
    }
  };

  #setFilters(value) {
    this.filtersOpen = value;
    if (value) {
      document.addEventListener("click", this.closeOnOutside);
    } else {
      document.removeEventListener("click", this.closeOnOutside);
    }
  }

  willDestroy() {
    super.willDestroy(...arguments);
    document.removeEventListener("click", this.closeOnOutside);
  }

  @action
  toggleFilters(event) {
    event.stopPropagation();
    this.#setFilters(!this.filtersOpen);
  }

  <template>
    {{#if this.onDiscovery}}
      <div class="sktvd-nav">
        <div class="sktvd-nav-inner">
          <nav class="sktvd-nav-tabs">
            {{#each this.tabs as |tab|}}
              <a
                href={{tab.href}}
                class="sktvd-nav-tab {{if tab.active 'is-active'}}"
              >
                {{#if tab.icon}}{{icon tab.icon}}{{/if}}
                <span>{{tab.label}}</span>
                {{#if tab.count}}
                  <span class="sktvd-nav-count">{{tab.count}}</span>
                {{/if}}
              </a>
            {{/each}}
          </nav>

          <div class="sktvd-nav-right">
            <div class="sktvd-nav-filters">
              <button
                type="button"
                class="sktvd-filters-btn {{if this.filtersOpen 'is-open'}}"
                {{on "click" this.toggleFilters}}
              >
                {{icon "filter"}}
                <span>Фильтры</span>
              </button>
              {{#if this.filtersOpen}}
                <div class="sktvd-filters-panel">
                  <div class="sktvd-filters-panel-head">Фильтр по разделу</div>
                  <a href="/latest" class="sktvd-filters-item">Все темы</a>
                  {{#each this.categories as |cat|}}
                    <a href={{cat.url}} class="sktvd-filters-item">
                      <span
                        class="sktvd-filters-dot"
                        style={{htmlSafe (concat "background:#" cat.color)}}
                      ></span>
                      {{cat.name}}
                    </a>
                  {{/each}}
                </div>
              {{/if}}
            </div>

            <a href="/new-topic" class="btn btn-primary sktvd-nav-create">
              {{icon "plus"}}
              <span>Создать тему</span>
            </a>
          </div>
        </div>
      </div>
    {{/if}}
  </template>
}
