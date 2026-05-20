// Connector for the `before-create-topic-button` plugin outlet — renders the
// "Фильтры" button in the discovery navigation row, just left of the
// "Создать тему" button, matching the mockup layout.
//
// Discourse has no single native "filter" button (filtering is the separate
// category/tag breadcrumb dropdowns); this is a small custom control. The
// button toggles a panel listing the forum's top-level categories — picking
// one navigates to that category's topic list, i.e. it actually filters.

import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import { service } from "@ember/service";
import { on } from "@ember/modifier";
import { concat } from "@ember/helper";
import { htmlSafe } from "@ember/template";
import icon from "discourse/helpers/d-icon";

export default class SktvdFilters extends Component {
  @service site;
  @tracked open = false;

  get categories() {
    return (this.site.categories || []).filter(
      (c) => !c.parent_category_id && !c.isUncategorizedCategory
    );
  }

  closeOnOutside = (event) => {
    if (!event.target.closest(".sktvd-filters")) {
      this.#setOpen(false);
    }
  };

  #setOpen(value) {
    this.open = value;
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
  toggle(event) {
    event.stopPropagation();
    this.#setOpen(!this.open);
  }

  <template>
    <div class="sktvd-filters">
      <button
        type="button"
        class="btn sktvd-filters-btn {{if this.open 'is-open'}}"
        {{on "click" this.toggle}}
      >
        {{icon "sliders"}}
        <span>Фильтры</span>
      </button>

      {{#if this.open}}
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
  </template>
}
