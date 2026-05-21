// Connector for the `discovery-list-container-top` plugin outlet. Renders a
// teaser of the 8 members-only categories (.sktvd-cat-teaser) for anonymous
// visitors.
//
// Why a static list and not a decoration of real category DOM: with
// `see=members` permissions Discourse does not send restricted categories to
// anonymous users at all — there is nothing in the DOM to blur. So the teaser
// is a hand-maintained list that mirrors seeds/categories. Keep it in sync if
// the taxonomy changes.

// Emoji mirror the real categories' emoji style_type (see
// scripts/category-emoji-apply.rb). Keep in sync if the taxonomy changes.
const CLOSED_CATEGORIES = [
  { emoji: "💬", name: "Общий разговор" },
  { emoji: "🐄", name: "Породы и генетика" },
  { emoji: "🌾", name: "Корма и пастбище" },
  { emoji: "🩺", name: "Ветеринария" },
  { emoji: "🚜", name: "Техника" },
  { emoji: "💰", name: "Купи-продай" },
  { emoji: "❓", name: "Вопросы новичков" },
  { emoji: "📚", name: "Документы" },
];

export default {
  shouldRender(args, component) {
    return settings.enable_guest_landing && !component.currentUser;
  },

  setupComponent(args, component) {
    component.setProperties({
      closedCategories: CLOSED_CATEGORIES,
      applicationUrl: settings.application_url,
    });
  },
};
