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

  // Имя тега: outletArgs.tag иногда отдаёт числовой route-param ("1"),
  // поэтому берём название из route-параметра tag_id, затем из URL.
  get tagName() {
    const t = this.args?.outletArgs?.tag;
    let name = t && (t.name || t.id);
    name = name == null ? null : String(name);
    if (!name || /^\d+$/.test(name)) {
      let route = this.router.currentRoute;
      while (route && !(route.params && route.params.tag_id)) {
        route = route.parent;
      }
      if (route?.params?.tag_id) {
        name = decodeURIComponent(route.params.tag_id);
      } else {
        const m = (this.router.currentURL || "").match(
          /\/tags?\/(?:intersection\/)?([^/?]+)/
        );
        name = m ? decodeURIComponent(m[1]) : null;
      }
    }
    return name;
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
    const tag = this.tagName;
    if (tag) {
      return {
        sectionLabel: "Теги",
        sectionHref: "/tags",
        current: tag,
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
