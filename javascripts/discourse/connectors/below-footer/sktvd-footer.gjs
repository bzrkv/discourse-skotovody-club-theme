// Connector for the `below-footer` outlet — the marketing footer.
//
// LANDING_SPEC §S10: a 4-column footer (brand · Клуб · Skotovody.com ·
// Контакты) plus a bottom strip. `below-footer` renders site-wide, so the
// component gates itself to the /membership route — every other Discourse
// page keeps its own (member) footer. When the full guest landing is built
// (handoff Task 2) it can render this same markup in its S10 slot; for now
// /membership is the only consumer.
//
// router.currentRouteName is tracked, so the {{#if}} re-evaluates on every
// client-side navigation — the footer appears/disappears with the route.

import Component from "@glimmer/component";
import { service } from "@ember/service";

export default class SktvdFooter extends Component {
  @service router;
  @service currentUser;

  get enabled() {
    if (this.router.currentRouteName === "membership") {
      return true;
    }
    // Guest landing: root path ("/"), anonymous visitor only
    const path = (this.router.currentURL || "").split("?")[0].replace(/\/+$/, "");
    return path === "" && !this.currentUser;
  }

  get applicationUrl() {
    return settings.application_url;
  }

  <template>
    {{#if this.enabled}}
      <footer class="sktvd-footer">
        <div class="sktvd-footer-inner">
          <div class="sktvd-footer-cols">

            {{! col 1 — brand }}
            <div class="sktvd-footer-brand">
              <span class="sktvd-footer-logo">
                <span class="sktvd-footer-logo-word">Скотоводы</span>
                <span class="sktvd-footer-logo-badge">КЛУБ</span>
              </span>
              <p class="sktvd-footer-tagline">
                Закрытое сообщество для тех, кто работает с мясным скотом.
                Часть экосистемы skotovody.com.
              </p>
            </div>

            {{! col 2 — Клуб }}
            <nav class="sktvd-footer-nav">
              <h3 class="sktvd-footer-h">Клуб</h3>
              <ul>
                <li><a href={{this.applicationUrl}}>Подать заявку</a></li>
                <li><a href="/session/sso">Войти</a></li>
                <li><a href="/membership">Тарифы и членство</a></li>
                <li><a href="/guidelines">Правила сообщества</a></li>
                <li><a href="/about">Помощь</a></li>
              </ul>
            </nav>

            {{! col 3 — Skotovody.com }}
            <nav class="sktvd-footer-nav">
              <h3 class="sktvd-footer-h">Skotovody.com</h3>
              <ul>
                <li><a href="https://skotovody.com/shop/">Каталог</a></li>
                <li><a href="https://skotovody.com/auctions/">Аукционы</a></li>
                <li><a href="https://skotovody.com/vendors/">Хозяйства</a></li>
                <li><a href="https://skotovody.com/blog/">База знаний</a></li>
              </ul>
            </nav>

            {{! col 4 — Контакты }}
            <nav class="sktvd-footer-nav">
              <h3 class="sktvd-footer-h">Контакты</h3>
              <ul>
                <li>
                  <a href="mailto:welcome@skotovody.com">welcome@skotovody.com</a>
                </li>
                <li>
                  <a
                    href="https://t.me/skotovody"
                    rel="noopener"
                    target="_blank"
                  >Telegram</a>
                </li>
                <li>
                  <a
                    href="https://vk.com/meatcattle"
                    rel="noopener"
                    target="_blank"
                  >VK</a>
                </li>
              </ul>
            </nav>

          </div>

          <div class="sktvd-footer-strip">
            {{! Юр-лицо: название ведёт на документ «Реквизиты»; детальные
                ИНН/ОГРН/адрес — там, не в футере. }}
            <span class="sktvd-footer-legal">
              <a href="/t/rekvizity/119">ООО «Кэттл Эксперт»</a>
              <span class="sktvd-footer-sep">·</span>
              <a href="/tos">Правила пользования</a>
              <span class="sktvd-footer-sep">·</span>
              <a href="/privacy">Политика конфиденциальности</a>
              <span class="sktvd-footer-sep">·</span>
              <a href="/c/legal/61">Правовая информация</a>
            </span>
            <span>© 2026 Skotovody. Все права защищены.</span>
          </div>
        </div>
      </footer>
    {{/if}}
  </template>
}
