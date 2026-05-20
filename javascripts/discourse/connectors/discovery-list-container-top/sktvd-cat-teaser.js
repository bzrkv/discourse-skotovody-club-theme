// Connector for the `discovery-list-container-top` plugin outlet. Renders a
// teaser of the 8 members-only categories (.sktvd-cat-teaser) for anonymous
// visitors.
//
// Why a static list and not a decoration of real category DOM: with
// `see=members` permissions Discourse does not send restricted categories to
// anonymous users at all — there is nothing in the DOM to blur. So the teaser
// is a hand-maintained list that mirrors seeds/categories. Keep it in sync if
// the taxonomy changes.

const CLOSED_CATEGORIES = [
  { name: "💬 Общий разговор", color: "#5B5247" },
  { name: "🐄 Породы и генетика", color: "#4A6B4A" },
  { name: "🌾 Корма и пастбище", color: "#7A8245" },
  { name: "🩺 Ветеринария", color: "#37503B" },
  { name: "🚜 Техника", color: "#5C677E" },
  { name: "💰 Купи-продай", color: "#8C6E2F" },
  { name: "❓ Вопросы новичков", color: "#5B7BA5" },
  { name: "📚 Документы", color: "#665845" },
];

export default {
  shouldRender(args, component) {
    return settings.enable_guest_landing && !component.currentUser;
  },

  setupComponent(args, component) {
    component.setProperties({
      closedCategories: CLOSED_CATEGORIES,
      pricingUrl: settings.pricing_url,
    });
  },
};
