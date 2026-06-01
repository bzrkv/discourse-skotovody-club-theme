// Connector for the `discovery-list-container-top` outlet — breadcrumb на
// страницах КАТЕГОРИЙ и ТЕГОВ (handoff club/screens/category.jsx §Breadcrumb):
// «Клуб › Категории › <Название>» / «Клуб › Теги › <тег>».
// На главной/ленте не показывается (там слайдер). Числовой префикс 0 —
// сортируется выше слайдера (sktvd-2-…).

import Component from "@glimmer/component";
import { service } from "@ember/service";
import icon from "discourse/helpers/d-icon";

export default class SktvdBreadcrumb extends Component {
  @service router;

  get category() {
    return this.args?.outletArgs?.category;
  }

  get tag() {
    return this.args?.outletArgs?.tag;
  }

  // Защита: на главной (/, /latest) крошку не показываем.
  get onListRoot() {
    const url = (this.router.currentURL || "/").split("?")[0];
    return url === "/" || url === "/latest";
  }

  get crumb() {
    if (this.onListRoot) {
      return null;
    }
    if (this.category) {
      return {
        sectionLabel: "Категории",
        sectionHref: "/categories",
        current: this.category.name,
      };
    }
    if (this.tag) {
      return {
        sectionLabel: "Теги",
        sectionHref: "/tags",
        current: this.tag.id || this.tag.name,
      };
    }
    return null;
  }

  <template>
    {{#if this.crumb}}
      <nav class="sktvd-breadcrumb" aria-label="Хлебные крошки">
        <a href="/">Клуб</a>
        {{icon "chevron-right"}}
        <a href={{this.crumb.sectionHref}}>{{this.crumb.sectionLabel}}</a>
        {{icon "chevron-right"}}
        <span class="sktvd-breadcrumb-current">{{this.crumb.current}}</span>
      </nav>
    {{/if}}
  </template>
}
