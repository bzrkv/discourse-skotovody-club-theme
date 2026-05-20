// Connector for the `discovery-list-container-top` plugin outlet — block E2
// of HOMEPAGE_SPEC: the notice strip that sits *under the slider* and *above*
// the topic list.
//
// Two mutually-exclusive variants, switched on `currentUser`:
//   - Member: a warm "fill your profile" nudge with «Позже» / «В профиль»
//     buttons (a profile-completion banner).
//   - Guest:  a quiet one-liner explaining that only «Новости и анонсы» is
//     public and the rest is members-only.
//
// File name `sktvd-2b-notice` places it alphabetically between
// `sktvd-2-slider` and `sktvd-3-teaser`, so the outlet renders it in the
// right slot (connectors in one outlet sort by file name).
//
// Interactive → `.gjs` glimmer component (`.hbs` + `(action)` is deprecated).

import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import { service } from "@ember/service";
import { on } from "@ember/modifier";
import icon from "discourse/helpers/d-icon";

// localStorage key for the member's «Позже» dismissal. Bump the suffix if the
// notice copy changes materially and you want it to re-surface for everyone.
const DISMISS_KEY = "sktvd_profile_notice_dismissed_v1";

// «Позже» snoozes the nudge for ~30 days, then it gently re-surfaces — a
// member who never got round to filling their profile is reminded again,
// but no more than once a month.
const SNOOZE_MS = 30 * 24 * 60 * 60 * 1000;

export default class SktvdNotice extends Component {
  @service currentUser;

  // Re-render trigger: flipped to `true` the moment «Позже» is clicked so the
  // strip disappears without a page reload.
  @tracked dismissedNow = false;

  // True while a past «Позже» click is still within its 30-day snooze window.
  // localStorage may throw (Safari private mode / storage disabled) — any
  // failure is treated as "not dismissed": better to show the nudge once too
  // often than to hide it because of a storage glitch.
  isDismissed() {
    try {
      const ts = parseInt(localStorage.getItem(DISMISS_KEY), 10);
      if (!ts) {
        return false;
      }
      return Date.now() - ts < SNOOZE_MS;
    } catch {
      return false;
    }
  }

  // Stores the click timestamp so isDismissed() can measure the snooze window.
  recordDismissal() {
    try {
      localStorage.setItem(DISMISS_KEY, String(Date.now()));
    } catch {
      // Storage unavailable — the notice simply re-shows next visit.
    }
  }

  // "Profile is filled in" — judged on the two identity signals available
  // synchronously on `currentUser` (no extra request): a real display name
  // and a non-default avatar. Letter (auto-generated) avatars carry
  // `letter_avatar` in their template. Both are required, which also means
  // OAuth signups (Yandex/VK pre-fill name + avatar) are never nagged.
  get profileComplete() {
    const u = this.currentUser;
    if (!u) {
      return false;
    }
    const hasName = Boolean(u.name && u.name.trim());
    const hasAvatar =
      Boolean(u.avatar_template) && !u.avatar_template.includes("letter_avatar");
    return hasName && hasAvatar;
  }

  get showMemberNotice() {
    return (
      Boolean(this.currentUser) &&
      !this.profileComplete &&
      !this.dismissedNow &&
      !this.isDismissed()
    );
  }

  get showGuestNotice() {
    return !this.currentUser;
  }

  @action
  dismiss() {
    this.recordDismissal();
    this.dismissedNow = true;
  }

  <template>
    {{#if this.showMemberNotice}}
      <div class="sktvd-notice">
        <div class="sktvd-notice-icon">
          {{icon "circle-info"}}
        </div>
        <div class="sktvd-notice-text">
          Заполните профиль — это поможет быстрее получить полезные ответы.
        </div>
        <button
          type="button"
          class="btn btn-secondary sktvd-notice-btn"
          {{on "click" this.dismiss}}
        >Позже</button>
        <a
          href="/my/preferences/profile"
          class="btn btn-primary sktvd-notice-btn"
        >В профиль</a>
      </div>
    {{else if this.showGuestNotice}}
      <div class="sktvd-notice-guest">
        {{icon "globe"}}
        <span>
          Раздел «<strong>Новости и анонсы</strong>» открыт публично · остальные
          ветки доступны участникам клуба
        </span>
      </div>
    {{/if}}
  </template>
}
