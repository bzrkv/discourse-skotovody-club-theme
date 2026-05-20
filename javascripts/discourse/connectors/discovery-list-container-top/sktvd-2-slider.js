// Connector for the `discovery-list-container-top` plugin outlet. Renders the
// auto-rotating hero slider (.sktvd-slider) above the topic list.
//
// Slides are authored by an admin in the `slides` theme setting (type: objects)
// — each slide has a kind (announce / event / partner), title, description and
// CTAs. This is content the admin curates; it does not depend on forum topics,
// so the hero shows from day one. If `slides` is empty the slider renders
// nothing (`{{#if this.slides}}` guards that in the template).

const ROTATE_MS = 7000;

export default {
  shouldRender() {
    return (
      settings.enable_slider &&
      Array.isArray(settings.slides) &&
      settings.slides.length > 0
    );
  },

  setupComponent(args, component) {
    const slides = settings.slides || [];
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
