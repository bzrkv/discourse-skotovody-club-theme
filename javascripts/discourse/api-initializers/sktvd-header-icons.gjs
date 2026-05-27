// Header icons: только chat (member-only). Bell + bookmark убраны 2026-05-27 —
// все нотификации и закладки доступны через avatar user-menu, дублировать в
// header нет смысла (user request: «убери "Избранное" и "Уведомление", всё
// есть в иконке пользователя, оставь только чат»).
//
// Remap нативной chat иконки (alias `d-chat` → solid `comment`) на outline
// `far-comment` сохраняем — это стилистическая правка под mockup.

import { apiInitializer } from "discourse/lib/api";

export default apiInitializer((api) => {
  api.replaceIcon("d-chat", "far-comment");
});
