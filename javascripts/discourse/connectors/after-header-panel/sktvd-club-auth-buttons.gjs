// Connector for the `after-header-panel` outlet — the right-hand header
// group for anonymous visitors: «Войти» + «Подать заявку».
//
// HOMEPAGE_SPEC §3 B1 places guest auth controls in the RIGHT group
// (positions 4а'/4б'), where members get their notification / chat / avatar
// row. An earlier build put them in `before-header-panel` (left, after the
// logo badge) — moved here to match the spec. This is a global connector:
// the change applies to the landing, /membership and every page uniformly.
//
// «Войти» MUST hit Discourse's own /session/sso entrypoint — that mints the
// signed DiscourseConnect nonce + return_sso_url. A native window.location
// assignment forces a full page load so Ember never client-routes this
// server-only path. «Подать заявку» points at the application form on
// skotovody.com — the same target every other «Подать заявку» CTA uses.

import Component from "@glimmer/component";
import { on } from "@ember/modifier";
import { service } from "@ember/service";

export default class SktvdClubAuthButtons extends Component {
  @service currentUser;

  applicationUrl = settings.application_url;

  login = () => {
    window.location.href =
      "/session/sso?return_path=" +
      encodeURIComponent(window.location.pathname);
  };

  <template>
    {{#unless this.currentUser}}
      <div class="sktvd-club-header-auth">
        <button
          type="button"
          class="btn sktvd-club-btn-login"
          title="Войти в Клуб"
          {{on "click" this.login}}
        >
          Войти
        </button>
        <a
          href={{this.applicationUrl}}
          class="btn btn-primary sktvd-club-btn-apply"
          title="Подать заявку на вступление в Клуб"
        >
          Подать заявку
        </a>
      </div>
    {{/unless}}
  </template>
}
