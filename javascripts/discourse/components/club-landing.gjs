// ClubLanding — the anonymous-visitor landing page. Sections S1-S9 per
// LANDING_SPEC.md (S10 footer is the separate sktvd-footer.gjs connector).
// Static marketing content lives in module constants below; only S5 pulls
// live data. Pattern reference: plugin component club-membership.gjs.

import Component from "@glimmer/component";
import icon from "discourse/helpers/d-icon";

// S1 stats strip — static marketing figures (LANDING_SPEC §S1)
const STATS = [
  { num: "4 218", label: "Скотоводов" },
  { num: "5 280", label: "Открытых тем" },
  { num: "83", label: "Региона" },
  { num: "36", label: "Ветврачей" },
  { num: "6+ лет", label: "С ноября 2019" },
];

const APPLICATION_URL = settings.application_url;

export default class ClubLanding extends Component {
  stats = STATS;
  applicationUrl = APPLICATION_URL;

  <template>
    <div class="sktvd-l">

      {{! ─── S1 · HERO ─── }}
      <section class="sktvd-l-hero" data-hero-photo>
        {{! Horizontal + vertical scrim for text readability (::before handled in CSS) }}
        <div class="sktvd-l-hero-scrim" aria-hidden="true"></div>

        <div class="sktvd-l-wrap sktvd-l-hero-body">
          {{! Left content column — max-width 580px per spec }}
          <div class="sktvd-l-hero-col">

            {{! Eyebrow pill }}
            <span class="sktvd-l-eyebrow-pill">
              {{icon "shield"}}
              Закрытое сообщество · с 11 ноября 2019
            </span>

            {{! H1 with ochre span }}
            <h1 class="sktvd-l-h1">
              Здесь — те, кто работает
              <span class="sktvd-l-h1-ochre">со&nbsp;скотом каждый день.</span>
            </h1>

            {{! Lead paragraph }}
            <p class="sktvd-l-lead">
              Сообщество выросло из Telegram-канала, открытого
              <strong>11 ноября 2019</strong>.
              Закрытая площадка для обмена реальным опытом мясного скотоводства —
              без рекламы, ботов и продаж в обход.
            </p>

            {{! CTA group: primary btn + ghost btn + trust-row }}
            <div class="sktvd-l-cta-group">
              <a href={{this.applicationUrl}} class="sktvd-l-btn-accent">
                {{icon "plus"}}
                Подать заявку
              </a>
              <a href="/membership" class="sktvd-l-btn-ghost">
                Тарифы клуба
              </a>

              {{! Inline trust-row }}
              <div class="sktvd-l-trust">
                {{! 4 placeholder avatar circles with -7px overlap }}
                <div class="sktvd-l-avatars" aria-hidden="true">
                  <span class="sktvd-l-av sktvd-l-av--1"></span>
                  <span class="sktvd-l-av sktvd-l-av--2"></span>
                  <span class="sktvd-l-av sktvd-l-av--3"></span>
                  <span class="sktvd-l-av sktvd-l-av--4"></span>
                </div>
                <span class="sktvd-l-trust-text">
                  <strong class="sktvd-l-trust-num">1 284</strong>
                  онлайн · 4 218 в клубе
                </span>
              </div>
            </div>

          </div>
        </div>

        {{! Stats strip — inside the dark hero zone, below content }}
        <div class="sktvd-l-stats-strip">
          <div class="sktvd-l-wrap sktvd-l-stats-inner">
            {{#each this.stats as |stat index|}}
              <div class="sktvd-l-stat {{if index 'has-border'}}">
                <div class="sktvd-l-stat-num">{{stat.num}}</div>
                <div class="sktvd-l-stat-lab">{{stat.label}}</div>
              </div>
            {{/each}}
          </div>
        </div>
      </section>

      {{! S2-S9 added in later tasks }}
    </div>
  </template>
}
