// ClubLanding — the anonymous-visitor landing page. Sections S1-S9 per
// LANDING_SPEC.md (S10 footer is the separate sktvd-footer.gjs connector).
// Static marketing content lives in module constants below; only S5 pulls
// live data. Pattern reference: plugin component club-membership.gjs.

import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import { fn } from "@ember/helper";
import { on } from "@ember/modifier";
import { eq } from "truth-helpers";
import { service } from "@ember/service";
import { ajax } from "discourse/lib/ajax";
import icon from "discourse/helpers/d-icon";

// S2 — why a closed community (LANDING_SPEC §S2)
const WHY = [
  { icon: "shield-halved", title: "Без рекламы и спама", text: "Внутри клуба не продают БАДы, кредиты и курсы. Только профильные обсуждения и проверенные объявления хозяйств.", textShort: "Не продают БАДы, кредиты и курсы" },
  { icon: "user", title: "Каждый — кто-то конкретный", text: "Анонимных аккаунтов нет. У каждого участника заполнен профиль: хозяйство, регион, специализация. Это меняет качество разговора.", textShort: "Аккаунтов без профиля нет" },
  { icon: "file-lines", title: "Ответы — от практиков", text: "Здесь не теоретизируют. Если кто-то отвечает про КЕ на телёнка — у него за плечами 200 голов и три зимы наблюдений.", textShort: "За плечами 200 голов и три зимы" },
];

// S3 — who it's for (GUEST_LANDING_UPDATE §S3). Icon plaque per persona,
// no «N участников» count badges (no invented numbers).
const PERSONAS = [
  { name: "Хозяйство", sub: "КФХ, ЛПХ, кооператив", icon: "house", tone: "forest", text: "Сравниваете породы, ищете быка-производителя с EPD, обсуждаете протоколы кормления и ветеринарии." },
  { name: "Ветеринар", sub: "Региональный или частный", icon: "shield-halved", tone: "terracotta", text: "Делитесь протоколами вакцинации, отслеживаете вспышки, советуетесь по сложным случаям." },
  { name: "Зоотехник", sub: "На крупных предприятиях", icon: "box-archive", tone: "ochre", text: "Расчёт КЕ, ротация пастбищ, ИО, племучёт — всё по делу, без теории «из учебника»." },
  { name: "Новичок", sub: "Делает первые шаги", icon: "wand-magic-sparkles", tone: "info", text: "Спрашиваете без боязни. Опытные участники подсказывают, а ответы попадают в Базу знаний." },
];

// S1 trust strip — qualitative claims, no invented numbers
// (GUEST_LANDING_UPDATE §S1 «Trust-полоса под hero»)
const TRUST = [
  { icon: "calendar-days", title: "С 11 ноября 2019", sub: "Шестой год в работе" },
  { icon: "shield-halved", title: "Закрытое сообщество", sub: "Вступление по заявке" },
  { icon: "layer-group", title: "9 разделов", sub: "От пород до техники" },
  { icon: "file-lines", title: "Без рекламы", sub: "Не продают БАДы и курсы" },
];

// Mobile trust grid — shorter labels for the compact 2×2 layout
// (GUEST_LANDING_UPDATE Часть 2 «Trust-сетка 2×2»)
const TRUST_MOBILE = [
  { icon: "calendar-days", title: "С ноября 2019", sub: "Шестой год" },
  { icon: "shield-halved", title: "По заявке", sub: "Каждый — проверен" },
  { icon: "wand-magic-sparkles", title: "9 разделов", sub: "От пород до техники" },
  { icon: "file-lines", title: "Без рекламы", sub: "Только по делу" },
];

// S4 — categories preview (LANDING_SPEC §S4, HOMEPAGE_SPEC §6)
// Verbatim from HOMEPAGE_SPEC §6 table. «Новости и анонсы» is the only
// public category (open: true → «Открыто» badge, links to /c/news).
// All other 8 have open: false → 🔒 badge, link to /membership.
const CATEGORIES = [
  {
    slug: "news",
    name: "Новости и анонсы",
    short: "Новости",
    color: "oklch(0.55 0.13 35)",        // --terracotta
    iconBg: "oklch(0.93 0.05 40)",        // terracotta-soft
    emoji: "📰",
    count: 412,
    sub: ["Официальные", "Анонсы", "Итоги"],
    open: true,
  },
  {
    slug: "general",
    name: "Общий разговор",
    short: "Общий",
    color: "oklch(0.40 0.02 60)",         // --ink-2
    iconBg: "oklch(0.92 0.012 75)",
    emoji: "💬",
    count: 1284,
    sub: ["Обсуждения", "Вопросы", "Знакомства"],
    open: false,
  },
  {
    slug: "breeds",
    name: "Породы и генетика",
    short: "Породы",
    color: "oklch(0.42 0.08 145)",        // --forest
    iconBg: "oklch(0.92 0.04 145)",       // forest-soft
    emoji: "🐄",
    count: 876,
    sub: ["Ангус", "Герефорд", "EPD"],
    open: false,
  },
  {
    slug: "feed",
    name: "Корма и пастбище",
    short: "Корма",
    color: "oklch(0.52 0.12 110)",
    iconBg: "oklch(0.93 0.06 110)",
    emoji: "🌾",
    count: 634,
    sub: ["Рационы", "Пастбищный", "Премиксы"],
    open: false,
  },
  {
    slug: "vet",
    name: "Ветеринария",
    short: "Ветеринария",
    color: "oklch(0.28 0.06 145)",        // --forest-ink
    iconBg: "oklch(0.92 0.04 145)",
    emoji: "💉",
    count: 748,
    sub: ["Вакцинация", "Протоколы", "Вспышки"],
    open: false,
  },
  {
    slug: "tech",
    name: "Техника",
    short: "Техника",
    color: "oklch(0.45 0.05 250)",
    iconBg: "oklch(0.92 0.025 250)",
    emoji: "⚙️",
    count: 391,
    sub: ["Трактора", "Оборудование", "Загоны"],
    open: false,
  },
  {
    slug: "market",
    name: "Купи-продай",
    short: "Купи-продай",
    color: "oklch(0.48 0.10 60)",         // --ochre-deep
    iconBg: "oklch(0.93 0.05 75)",        // ochre-soft
    emoji: "🤝",
    count: 522,
    sub: ["КРС", "Техника", "Корма"],
    open: false,
  },
  {
    slug: "newbie",
    name: "Вопросы новичков",
    short: "Новичкам",
    color: "oklch(0.50 0.10 230)",
    iconBg: "oklch(0.92 0.04 230)",
    emoji: "🌱",
    count: 467,
    sub: ["Старт", "База знаний", "Помощь"],
    open: false,
  },
  {
    slug: "docs",
    name: "Документы",
    short: "Документы",
    color: "oklch(0.42 0.04 60)",
    iconBg: "oklch(0.91 0.018 75)",
    emoji: "📋",
    count: 198,
    sub: ["Шаблоны", "Нормативы", "Отчёты"],
    open: false,
  },
];

// S6 — testimonials (LANDING_SPEC §S6). Реальные участники клуба.
const TESTIMONIALS = [
  { name: "Александр Москвин", role: "Глава КФХ", loc: "Ленинградская обл.", quote: "Я основал этот клуб в 2019 и поддерживаю его с первого дня. Мы занимаемся абердин-ангусом — здесь собрались практики, которым важно делиться опытом без рекламы и без посредников." },
  { name: "Александр Дильдин", role: "Глава КФХ", loc: "Ленинградская обл.", quote: "Помогаю новичкам разобраться: какие породы под их регион, с чего начать, к кому обратиться. За эти годы в клубе сложилась практика поддержки — каждый, кто заходит впервые, получает развёрнутые ответы." },
  { name: "Екатерина Зимина", role: "Ветеринарный врач", loc: "Санкт-Петербург", quote: "Делюсь международным опытом ветеринарии и зоотехники. В клубе обсуждаем реальные случаи — протоколы вакцинации, кормление, племенную работу. Это уровень разговора, которого не найти в общих рассылках." },
];

// S7 — how to join (LANDING_SPEC §S7)
const STEPS = [
  { n: "01", title: "Заявка", text: "Заполняете короткую форму: хозяйство, регион, специализация, ссылка на инстаграм или сайт, если есть. Это 2 минуты.", textShort: "Короткая форма: хозяйство, регион, специализация. Две минуты." },
  { n: "02", title: "Проверка", text: "Команда клуба смотрит вашу заявку и связывается, если нужны уточнения. Решение — в течение одного рабочего дня.", textShort: "Решение — в течение одного рабочего дня." },
  { n: "03", title: "Доступ", text: "Открываются все 9 разделов. Можно создавать темы, отвечать, отмечать закладки, писать в личные сообщения и пользоваться Базой знаний.", textShort: "Открываются все 9 разделов и личные сообщения." },
];

// S7.5 — pricing teaser mini-cards (LANDING_SPEC §S7.5)
const TEASER_TIERS = [
  { tag: "Основной", name: "Действительный", sub: "Фермер · КФХ · ЛПХ", price: "15 000 ₽/год", tone: "forest" },
  { tag: "Бизнес", name: "Ассоциированный", sub: "Поставщики", price: "30 000 ₽/год", tone: "ochre" },
  { tag: "По приглашению", name: "Почётный", sub: "Эксперты · студенты", price: "0 ₽", tone: "terracotta" },
];

// S8 — FAQ accordion (LANDING_SPEC §S8)
const FAQ = [
  {
    q: "Это платно?",
    a: "Базовое участие в клубе — бесплатно. Платными могут быть отдельные мастер-классы, AMA с экспертами и платные объявления хозяйств — это редкие исключения и они всегда отмечены.",
  },
  {
    q: "Меня могут не принять?",
    a: "Если профиль явно фейковый или ничего не указывает на причастность к мясному скотоводству — да. Конкретного «гейткипера» нет, мы просто хотим понимать, кто заходит.",
  },
  {
    q: "Можно ли продавать скот в клубе?",
    a: "Частные объявления — только в разделе «Купи-продай», и без коммерческих сетей хозяйств (их место в каталоге skotovody.com). Продавать в обход — повод для блокировки.",
  },
  {
    q: "Связан ли клуб с skotovody.com?",
    a: "Да, это часть одной экосистемы. Каталог хозяйств, аукционы и База знаний — на skotovody.com, клуб — это сообщество и площадка обсуждения. Аккаунты единые.",
  },
  {
    q: "Как защищены мои данные?",
    a: "Регистрация только через email и проверенный профиль. В клубе нет публичного API, индексация поисковиками отключена (кроме раздела «Новости»). Удалить аккаунт можно в один клик.",
  },
  {
    q: "Что делать, если мне неудобно или сложно?",
    a: "Напишите в личку @admin или в раздел «Вопросы новичков» — здесь принято помогать. На каждый вопрос приходят 3–5 ответов с практикой.",
  },
];

const APPLICATION_URL = settings.application_url;

export default class ClubLanding extends Component {
  @service site;

  trust = TRUST;
  trustMobile = TRUST_MOBILE;
  why = WHY;
  personas = PERSONAS;
  categories = CATEGORIES;
  applicationUrl = APPLICATION_URL;
  testimonials = TESTIMONIALS;
  steps = STEPS;
  teaserTiers = TEASER_TIERS;
  faq = FAQ;

  // S5 — public news fetch
  @tracked news = null;

  // S8 — FAQ accordion state; first item open by default
  @tracked openFaq = 0;

  // Layout branch — desktop 10-section vs mobile compact. Discourse 2026 is
  // fully responsive (site.mobileView is unreliable), so branch on viewport.
  @tracked isMobile = false;

  @action
  toggleFaq(index) {
    this.openFaq = this.openFaq === index ? -1 : index;
  }

  constructor() {
    super(...arguments);
    this.#loadNews();

    // Viewport-width layout branch (≤768px → mobile compact layout)
    if (typeof window !== "undefined" && window.matchMedia) {
      this._mq = window.matchMedia("(max-width: 768px)");
      this.isMobile = this._mq.matches;
      this._mqHandler = (e) => (this.isMobile = e.matches);
      this._mq.addEventListener("change", this._mqHandler);
    }
  }

  willDestroy() {
    super.willDestroy(...arguments);
    this._mq?.removeEventListener("change", this._mqHandler);
  }

  async #loadNews() {
    try {
      const data = await ajax("/c/news/5.json");
      // data.users is a flat array keyed by id; build a map for O(1) lookups
      const usersById = {};
      if (Array.isArray(data.users)) {
        for (const u of data.users) {
          usersById[u.id] = u;
        }
      }

      // Exclude the category's auto-generated "About …" definition topic.
      // Prefer the id from the site category record; fall back to the known
      // definition topic id for category 5 if the record is unavailable.
      const newsCat = this.site?.categories?.find((c) => c.id === 5);
      const definitionId = newsCat?.topic_id ?? 7;

      const list = (data?.topic_list?.topics || [])
        .filter((t) => !t.pinned_globally && t.id !== definitionId)
        .slice(0, 3)
        .map((t) => {
          // Resolve author: prefer the poster whose description contains
          // "Original Poster", fall back to posters[0], fall back to null.
          let author = null;
          if (Array.isArray(t.posters) && t.posters.length > 0) {
            const opEntry =
              t.posters.find((p) =>
                (p.description || "").includes("Original Poster")
              ) || t.posters[0];
            if (opEntry) {
              author = usersById[opEntry.user_id] || null;
            }
          }
          return { ...t, _author: author };
        });
      this.news = list;
    } catch {
      this.news = []; // S5 hides itself on failure
    }
  }

  <template>
    <div class="sktvd-l">
      {{! ─── S1 · HERO — единый для desktop и mobile (фото + CTA),
           адаптируется через CSS media queries. Отдельная mobile-card
           раскладка (sktvd-lm-*) была отключена 2026-05-27 — теряла
           hero-фото и оставшийся контент S2-S9 на mobile. ─── }}
      <section class="sktvd-l-hero" data-hero-photo>
        {{! Horizontal + vertical scrim for text readability (::before handled in CSS) }}
        <div class="sktvd-l-hero-scrim" aria-hidden="true"></div>

        <div class="sktvd-l-wrap sktvd-l-hero-body">
          {{! Left content column — max-width 580px per spec }}
          <div class="sktvd-l-hero-col">

            {{! Eyebrow pill }}
            <span class="sktvd-l-eyebrow-pill">
              {{icon "shield-halved"}}
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

              {{! Inline trust-row — participant types, no numbers }}
              <div class="sktvd-l-trust">
                {{! 4 placeholder avatar circles with -7px overlap }}
                <div class="sktvd-l-avatars" aria-hidden="true">
                  <span class="sktvd-l-av sktvd-l-av--1"></span>
                  <span class="sktvd-l-av sktvd-l-av--2"></span>
                  <span class="sktvd-l-av sktvd-l-av--3"></span>
                  <span class="sktvd-l-av sktvd-l-av--4"></span>
                </div>
                <span class="sktvd-l-trust-text">фермеры, ветврачи, зоотехники</span>
              </div>
            </div>

          </div>
        </div>

        {{! Trust strip — inside the dark hero zone, below content.
            4 qualitative claims, no invented numbers }}
        <div class="sktvd-l-trust-strip">
          <div class="sktvd-l-wrap sktvd-l-trust-strip-inner">
            {{#each this.trust as |item index|}}
              <div class="sktvd-l-trust-item {{if index 'has-border'}}">
                <span class="sktvd-l-trust-item-icon" aria-hidden="true">
                  {{icon item.icon}}
                </span>
                <div class="sktvd-l-trust-item-body">
                  <div class="sktvd-l-trust-item-title">{{item.title}}</div>
                  <div class="sktvd-l-trust-item-sub">{{item.sub}}</div>
                </div>
              </div>
            {{/each}}
          </div>
        </div>
      </section>

      {{! ─── S2 · WHY CLOSED — shared (desktop + mobile, responsive) ─── }}
      <section class="sktvd-l-why">
        <div class="sktvd-l-wrap">
          <div class="sktvd-l-why-head">
            <p class="sktvd-l-why-eyebrow">Почему закрытое</p>
            <h2 class="sktvd-l-why-h2">Доступ только для своих — это качество ответов.</h2>
          </div>

          <div class="sktvd-l-why-grid">
            {{#each this.why as |item|}}
              <div class="sktvd-l-why-card">
                <div class="sktvd-l-why-icon" aria-hidden="true">
                  {{icon item.icon}}
                </div>
                <h3 class="sktvd-l-why-h3">{{item.title}}</h3>
                <p class="sktvd-l-why-text sktvd-l-text-full">{{item.text}}</p>
                <p class="sktvd-l-why-text sktvd-l-text-short">{{item.textShort}}</p>
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
                <span class="sktvd-l-who-icon" aria-hidden="true">
                  {{icon persona.icon}}
                </span>
                <h3 class="sktvd-l-who-name">{{persona.name}}</h3>
                <p class="sktvd-l-who-sub">{{persona.sub}}</p>
                <p class="sktvd-l-who-text">{{persona.text}}</p>
              </div>
            {{/each}}
          </div>
        </div>
      </section>

      {{! ─── S4 · CATEGORIES PREVIEW ─── }}
      <section class="sktvd-l-cats">
        <div class="sktvd-l-wrap">
          <div class="sktvd-l-cats-head">
            <p class="sktvd-l-cats-eyebrow">Разделы клуба</p>
            <h2 class="sktvd-l-cats-h2">9 разделов — структура работы хозяйства</h2>
          </div>

          <div class="sktvd-l-cats-grid">
            {{#each this.categories as |cat|}}
              <a
                href={{if cat.open "/c/news" "/membership"}}
                class="sktvd-l-cats-card {{if cat.open 'is-open'}}"
                style="--cat-color: {{cat.color}}; --cat-icon-bg: {{cat.iconBg}}"
              >
                {{! Left colour bar — rendered via ::before in CSS }}
                <div class="sktvd-l-cats-card-top">
                  <div class="sktvd-l-cats-icon" aria-hidden="true">
                    <span class="sktvd-l-cats-emoji">{{cat.emoji}}</span>
                  </div>
                  <div class="sktvd-l-cats-meta">
                    <span class="sktvd-l-cats-name sktvd-l-cats-name-full">{{cat.name}}</span>
                    <span class="sktvd-l-cats-name sktvd-l-cats-name-short">{{cat.short}}</span>
                  </div>
                  {{#if cat.open}}
                    <span class="sktvd-l-cats-badge is-open">Открыто</span>
                  {{else}}
                    <span class="sktvd-l-cats-badge is-locked" aria-hidden="true">🔒</span>
                  {{/if}}
                </div>
                <div class="sktvd-l-cats-sub">{{cat.sub.[0]}} · {{cat.sub.[1]}} · {{cat.sub.[2]}}</div>
              </a>
            {{/each}}
          </div>
        </div>
      </section>

      {{! ─── S5 · PUBLIC NEWS — shared (desktop + mobile) ─── }}
      {{#if this.news.length}}
        <section class="sktvd-l-news">
          <div class="sktvd-l-wrap">
            <div class="sktvd-l-news-head">
              <div class="sktvd-l-news-head-left">
                <p class="sktvd-l-news-eyebrow">Открытые новости</p>
                <h2 class="sktvd-l-news-h2">Свежие новости и анонсы</h2>
              </div>
              <a href="/c/news" class="sktvd-l-news-all">Открыть раздел «Новости» →</a>
            </div>

            <div class="sktvd-l-news-grid">
              {{#each this.news as |topic|}}
                <a
                  href="/t/{{topic.slug}}/{{topic.id}}"
                  class="sktvd-l-news-card"
                >
                  <span class="sktvd-l-news-chip" aria-label="Категория: Новости">
                    <span class="sktvd-l-news-chip-dot" aria-hidden="true"></span>
                    Новости
                  </span>

                  <h3 class="sktvd-l-news-title">{{topic.title}}</h3>

                  <div class="sktvd-l-news-footer">
                    {{#if topic._author}}
                      <img
                        class="sktvd-l-news-avatar"
                        src="/user_avatar/club.skotovody.com/{{topic._author.username}}/22/{{topic._author.avatar_template}}"
                        alt={{topic._author.username}}
                        width="22"
                        height="22"
                        loading="lazy"
                      />
                      <span class="sktvd-l-news-author">{{topic._author.username}}</span>
                      <span class="sktvd-l-news-sep" aria-hidden="true">·</span>
                    {{/if}}
                    <span class="sktvd-l-news-time">{{topic.created_at}}</span>
                    <span class="sktvd-l-news-replies">{{topic.reply_count}} отв.</span>
                  </div>
                </a>
              {{/each}}
            </div>
          </div>
        </section>
      {{/if}}

      {{! ─── S6 · TESTIMONIALS ─── }}
      <section class="sktvd-l-quotes">
        <div class="sktvd-l-wrap">
          <div class="sktvd-l-quotes-head">
            <p class="sktvd-l-quotes-eyebrow">Голоса участников</p>
            <h2 class="sktvd-l-quotes-h2">Кто уже в клубе и зачем</h2>
          </div>

          <div class="sktvd-l-quotes-grid">
            {{#each this.testimonials as |quote|}}
              <div class="sktvd-l-quote-card">
                <div class="sktvd-l-quote-mark" aria-hidden="true">"</div>
                <p class="sktvd-l-quote-text">{{quote.quote}}</p>
                <footer class="sktvd-l-quote-footer">
                  {{! Initials avatar — placeholder colour circle }}
                  <span class="sktvd-l-quote-av" aria-hidden="true">
                    {{! first letter of name }}
                  </span>
                  <div class="sktvd-l-quote-author">
                    <span class="sktvd-l-quote-name">{{quote.name}}</span>
                    <span class="sktvd-l-quote-meta">{{quote.role}} · {{quote.loc}}</span>
                  </div>
                </footer>
              </div>
            {{/each}}
          </div>
        </div>
      </section>

      {{! ─── S7 · HOW TO JOIN ─── }}
      <section class="sktvd-l-steps">
        <div class="sktvd-l-wrap">
          <div class="sktvd-l-steps-head">
            <p class="sktvd-l-steps-eyebrow">Вступление</p>
            <h2 class="sktvd-l-steps-h2">Три шага и день ожидания</h2>
          </div>

          <div class="sktvd-l-steps-grid">
            {{#each this.steps as |step|}}
              <div class="sktvd-l-step-card">
                <div class="sktvd-l-step-num" aria-hidden="true">{{step.n}}</div>
                <div class="sktvd-l-step-body">
                  <h3 class="sktvd-l-step-title">{{step.title}}</h3>
                  <p class="sktvd-l-step-text sktvd-l-text-full">{{step.text}}</p>
                  <p class="sktvd-l-step-text sktvd-l-text-short">{{step.textShort}}</p>
                </div>
              </div>
            {{/each}}
          </div>
        </div>
      </section>

      {{! ─── S7.5 · PRICING TEASER ─── }}
      <section class="sktvd-l-teaser">
        <div class="sktvd-l-wrap">
          <div class="sktvd-l-teaser-box">
            <div class="sktvd-l-teaser-grid">

              {{! Left column — eyebrow + h2 + lead + CTA }}
              <div class="sktvd-l-teaser-left">
                <p class="sktvd-l-teaser-eyebrow">Стоимость членства</p>
                <h2 class="sktvd-l-teaser-h2">Три категории · цена зависит от роли</h2>
                <p class="sktvd-l-teaser-lead">Тариф подбирается автоматически из ответа в форме заявки. Платите после одобрения.</p>
                <a href="/membership" class="sktvd-l-teaser-cta">
                  Открыть страницу тарифов →
                </a>
              </div>

              {{! Right column — 3 mini tier-cards }}
              <div class="sktvd-l-teaser-cards">
                {{#each this.teaserTiers as |tier|}}
                  <div class="sktvd-l-teaser-card --{{tier.tone}}">
                    <span class="sktvd-l-teaser-card-tag">{{tier.tag}}</span>
                    <div class="sktvd-l-teaser-card-name">{{tier.name}}</div>
                    <div class="sktvd-l-teaser-card-sub">{{tier.sub}}</div>
                    <div class="sktvd-l-teaser-card-price">{{tier.price}}</div>
                  </div>
                {{/each}}
              </div>

            </div>
          </div>
        </div>
      </section>

      {{! ─── S8 · FAQ ─── }}
      <section class="sktvd-l-faq">
        <div class="sktvd-l-wrap sktvd-l-faq-inner">
          <div class="sktvd-l-faq-head">
            <p class="sktvd-l-faq-eyebrow">Вопросы и ответы</p>
            <h2 class="sktvd-l-faq-h2">Что обычно спрашивают</h2>
          </div>
          <div class="sktvd-l-acc">
            {{#each this.faq as |faqItem index|}}
              <div class="sktvd-l-acc-item">
                <button
                  type="button"
                  class="sktvd-l-acc-q"
                  {{on "click" (fn this.toggleFaq index)}}
                >
                  <span>{{faqItem.q}}</span>
                  <span
                    class="sktvd-l-acc-toggle {{if (eq this.openFaq index) 'is-open'}}"
                  >+</span>
                </button>
                {{#if (eq this.openFaq index)}}
                  <div class="sktvd-l-acc-a">{{faqItem.a}}</div>
                {{/if}}
              </div>
            {{/each}}
          </div>
        </div>
      </section>

      {{! ─── S9 · FINAL CTA ─── }}
      <section class="sktvd-l-final">
        <div class="sktvd-l-wrap">
          <div class="sktvd-l-final-banner">
            <div class="sktvd-l-final-left">
              <h2 class="sktvd-l-final-h2">Готовы вступить?</h2>
              <p class="sktvd-l-final-lead sktvd-l-text-full">
                Заполнение заявки занимает две минуты. Мы рассмотрим её в течение одного рабочего дня и откроем доступ ко всем 9 разделам.
              </p>
              <p class="sktvd-l-final-lead sktvd-l-text-short">
                Заявка — две минуты. Рассмотрим за один рабочий день.
              </p>
              <div class="sktvd-l-final-cta-row">
                <a href={{this.applicationUrl}} class="sktvd-l-btn-accent --lg">
                  {{icon "plus"}}
                  Подать заявку
                </a>
                <a href="/c/news" class="sktvd-l-btn-ghost --dark --lg">
                  <span class="sktvd-l-text-full">Сначала почитать новости</span>
                  <span class="sktvd-l-text-short">Новости</span>
                </a>
              </div>
            </div>
            <div class="sktvd-l-final-right" aria-hidden="true">
              <span class="sktvd-l-final-watermark">JOIN</span>
            </div>
          </div>
        </div>
      </section>

    </div>
  </template>
}
