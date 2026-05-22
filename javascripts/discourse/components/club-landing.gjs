// ClubLanding — the anonymous-visitor landing page. Sections S1-S9 per
// LANDING_SPEC.md (S10 footer is the separate sktvd-footer.gjs connector).
// Static marketing content lives in module constants below; only S5 pulls
// live data. Pattern reference: plugin component club-membership.gjs.

import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { service } from "@ember/service";
import { ajax } from "discourse/lib/ajax";
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

// S4 — categories preview (LANDING_SPEC §S4, HOMEPAGE_SPEC §6)
// Verbatim from HOMEPAGE_SPEC §6 table. «Новости и анонсы» is the only
// public category (open: true → «Открыто» badge, links to /c/news).
// All other 8 have open: false → 🔒 badge, link to /membership.
const CATEGORIES = [
  {
    slug: "news",
    name: "Новости и анонсы",
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
    color: "oklch(0.42 0.04 60)",
    iconBg: "oklch(0.91 0.018 75)",
    emoji: "📋",
    count: 198,
    sub: ["Шаблоны", "Нормативы", "Отчёты"],
    open: false,
  },
];

const APPLICATION_URL = settings.application_url;

export default class ClubLanding extends Component {
  @service site;

  stats = STATS;
  why = WHY;
  personas = PERSONAS;
  categories = CATEGORIES;
  applicationUrl = APPLICATION_URL;

  // S5 — public news fetch
  @tracked news = null;

  constructor() {
    super(...arguments);
    this.#loadNews();
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

      {{! ─── S4 · CATEGORIES PREVIEW ─── }}
      <section class="sktvd-l-cats">
        <div class="sktvd-l-wrap">
          <div class="sktvd-l-cats-head">
            <div class="sktvd-l-cats-head-left">
              <p class="sktvd-l-cats-eyebrow">Разделы клуба</p>
              <h2 class="sktvd-l-cats-h2">9 разделов — структура работы хозяйства</h2>
            </div>
            <div class="sktvd-l-cats-head-right">5 280 тем · 68 920 сообщений</div>
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
                    <span class="sktvd-l-cats-name">{{cat.name}}</span>
                    <span class="sktvd-l-cats-count">{{cat.count}} тем</span>
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

      {{! ─── S5 · PUBLIC NEWS ─── }}
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

      {{! S6-S9 added in later tasks }}
    </div>
  </template>
}
