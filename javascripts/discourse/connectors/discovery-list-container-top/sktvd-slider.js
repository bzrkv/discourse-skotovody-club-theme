// Connector for the `discovery-list-container-top` plugin outlet. Renders an
// auto-rotating announcement slider (.sktvd-slider) above the topic list.
//
// Slides are the most recent topics carrying the `slider_tag` theme setting
// (default "announcement"), fetched from Discourse's tag endpoint. If there
// are no such topics the slider renders nothing — `{{#if this.slides}}` in the
// template guards that case, so a fresh forum simply shows no slider.

import { ajax } from "discourse/lib/ajax";

const ROTATE_MS = 7000;

export default {
  shouldRender() {
    return settings.enable_slider;
  },

  setupComponent(args, component) {
    component.setProperties({ slides: null, current: null, index: 0 });

    ajax(`/tag/${encodeURIComponent(settings.slider_tag)}.json`)
      .then((result) => {
        if (component.isDestroying || component.isDestroyed) {
          return;
        }
        const topics = (result.topic_list && result.topic_list.topics) || [];
        const slides = topics.slice(0, settings.slider_count).map((t) => ({
          title: t.title,
          excerpt: t.excerpt || "",
          url: `/t/${t.slug}/${t.id}`,
        }));

        if (!slides.length) {
          return;
        }
        component.setProperties({ slides, current: slides[0], index: 0 });

        if (slides.length > 1) {
          component._sktvdTimer = setInterval(() => {
            if (component.isDestroying || component.isDestroyed) {
              return;
            }
            const next = (component.index + 1) % slides.length;
            component.setProperties({ index: next, current: slides[next] });
          }, ROTATE_MS);
        }
      })
      .catch(() => {
        // tag endpoint failed or tag has no topics — leave slider hidden
      });
  },

  teardownComponent(component) {
    if (component._sktvdTimer) {
      clearInterval(component._sktvdTimer);
    }
  },

  actions: {
    goTo(i) {
      this.setProperties({ index: i, current: this.slides[i] });
    },
    step(delta) {
      const n = this.slides.length;
      const i = (this.index + delta + n) % n;
      this.setProperties({ index: i, current: this.slides[i] });
    },
  },
};
