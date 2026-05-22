// ClubLanding — the anonymous-visitor landing page. Sections S1-S9 per
// LANDING_SPEC.md (S10 footer is the separate sktvd-footer.gjs connector).
// Static marketing content lives in module constants below; only S5 pulls
// live data. Pattern reference: plugin component club-membership.gjs.

import Component from "@glimmer/component";
import icon from "discourse/helpers/d-icon";

// S2 — why a closed community (LANDING_SPEC §S2)
const WHY = [
  { icon: "shield", title: "Без рекламы и спама", text: "Внутри клуба не продают БАДы, кредиты и курсы. Только профильные обсуждения и проверенные объявления хозяйств." },
  { icon: "user", title: "Каждый — кто-то конкретный", text: "Анонимных аккаунтов нет. У каждого участника заполнен профиль: хозяйство, регион, специализация. Это меняет качество разговора." },
  { icon: "file-lines", title: "Ответы — от практиков", text: "Здесь не теоретизируют. Если кто-то отвечает про КЕ на телёнка — у него за плечами 200 голов и три зимы наблюдений." },
];

// S3 — who it's for (LANDING_SPEC §S3)
const PERSONAS = [
  { name: "Хозяйство", sub: "50–500 голов", count: "2 140", tone: "forest", text: "Сравниваете породы, ищете быка-производителя с EPD, обсуждаете протоколы кормления и ветеринарии." },
  { name: "Ветеринар", sub: "Региональный или частный", count: "420", tone: "terracotta", text: "Делитесь протоколами вакцинации, отслеживаете вспышки, советуетесь по сложным случаям." },
  { name: "Зоотехник", sub: "На крупных предприятиях", count: "880", tone: "ochre", text: "Расчёт КЕ, ротация пастбищ, ИО, племучёт — всё по делу, без теории «из учебника»." },
  { name: "Новичок", sub: "Делает первые шаги", count: "780", tone: "info", text: "Спрашиваете без боязни. Опытные участники подсказывают, а ответы попадают в Базу знаний." },
];

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
  why = WHY;
  personas = PERSONAS;
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

      {{! ─── S2 · WHY CLOSED ─── }}
      <section class="sktvd-l-why">
        <div class="sktvd-l-wrap">
          <div class="sktvd-l-why-head">
            <p class="sktvd-l-why-eyebrow">Закрытый формат</p>
            <h2 class="sktvd-l-why-h2">Доступ только для своих — это не снобизм. Это качество ответов.</h2>
          </div>

          <div class="sktvd-l-why-grid">
            {{#each this.why as |item|}}
              <div class="sktvd-l-why-card">
                <div class="sktvd-l-why-icon" aria-hidden="true">
                  {{icon item.icon}}
                </div>
                <h3 class="sktvd-l-why-h3">{{item.title}}</h3>
                <p class="sktvd-l-why-text">{{item.text}}</p>
              </div>
            {{/each}}
          </div>
        </div>
      </section>

      {{! ─── S3 · WHO FOR ─── }}
      <section class="sktvd-l-who">
        <div class="sktvd-l-wrap">
          <div class="sktvd-l-who-head">
            <p class="sktvd-l-who-eyebrow">Для кого</p>
            <h2 class="sktvd-l-who-h2">Подходит, если вы…</h2>
          </div>

          <div class="sktvd-l-who-grid">
            {{#each this.personas as |persona|}}
              <div class="sktvd-l-who-card --{{persona.tone}}">
                <span class="sktvd-l-who-pill">{{persona.count}} участников</span>
                <h3 class="sktvd-l-who-name">{{persona.name}}</h3>
                <p class="sktvd-l-who-sub">{{persona.sub}}</p>
                <p class="sktvd-l-who-text">{{persona.text}}</p>
              </div>
            {{/each}}
          </div>
        </div>
      </section>

      {{! S4-S9 added in later tasks }}
    </div>
  </template>
}
