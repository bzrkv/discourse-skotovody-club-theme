// Connector for the `discovery-list-container-top` plugin outlet — the
// auto-rotating hero slider (.sktvd-slider) above the topic list.
//
// Written as a modern .gjs glimmer component (not the deprecated
// .hbs + setupComponent connector API): @tracked state + native click
// handlers, so rotation and the dots/arrows actually update reactively.
//
// Slides come from the `slides` theme setting (type: objects) — content the
// admin curates, independent of forum topics, so the hero shows from day one.

import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import { fn } from "@ember/helper";
import { on } from "@ember/modifier";
import { eq, gt } from "truth-helpers";

const ROTATE_MS = 7000;

export default class SktvdSlider extends Component {
  slides = Array.isArray(settings.slides) ? settings.slides : [];
  @tracked index = 0;

  constructor() {
    super(...arguments);
    if (this.enabled && this.slides.length > 1) {
      this._timer = setInterval(() => {
        this.index = (this.index + 1) % this.slides.length;
      }, ROTATE_MS);
    }
  }

  willDestroy() {
    super.willDestroy(...arguments);
    if (this._timer) {
      clearInterval(this._timer);
    }
  }

  get enabled() {
    return settings.enable_slider && this.slides.length > 0;
  }

  get current() {
    return this.slides[this.index];
  }

  @action
  goTo(i) {
    this.index = i;
    this.#pause();
  }

  @action
  step(delta) {
    const n = this.slides.length;
    this.index = (this.index + delta + n) % n;
    this.#pause();
  }

  // Stop auto-rotation once the visitor interacts with the slider.
  #pause() {
    if (this._timer) {
      clearInterval(this._timer);
      this._timer = null;
    }
  }

  <template>
    {{#if this.enabled}}
      <div class="sktvd-slider">
        <div class="sktvd-slider-slide --{{this.current.kind}}">
          <div class="sktvd-slider-main">
            {{#if this.current.tag}}
              <span class="sktvd-slider-tag">{{this.current.tag}}</span>
            {{/if}}
            <h2 class="sktvd-slider-title">{{this.current.title}}</h2>
            {{#if this.current.description}}
              <p class="sktvd-slider-desc">{{this.current.description}}</p>
            {{/if}}
            {{#if this.current.event_when}}
              <p class="sktvd-slider-when">{{this.current.event_when}}</p>
            {{/if}}
            <div class="sktvd-slider-cta">
              {{#if this.current.cta_url}}
                <a href={{this.current.cta_url}} class="btn btn-primary">
                  {{this.current.cta_text}}
                </a>
              {{/if}}
              {{#if this.current.cta_alt_url}}
                <a
                  href={{this.current.cta_alt_url}}
                  class="btn sktvd-slider-cta-alt"
                >{{this.current.cta_alt_text}}</a>
              {{/if}}
            </div>
          </div>
          {{#if this.current.watermark}}
            <div class="sktvd-slider-watermark">{{this.current.watermark}}</div>
          {{/if}}
        </div>

        {{#if (gt this.slides.length 1)}}
          <button
            type="button"
            class="sktvd-slider-arrow prev"
            aria-label="Предыдущий слайд"
            {{on "click" (fn this.step -1)}}
          >‹</button>
          <button
            type="button"
            class="sktvd-slider-arrow next"
            aria-label="Следующий слайд"
            {{on "click" (fn this.step 1)}}
          >›</button>

          <div class="sktvd-slider-dots">
            {{#each this.slides as |slide i|}}
              <button
                type="button"
                class="sktvd-slider-dot"
                aria-current={{if (eq i this.index) "true" "false"}}
                aria-label="Слайд"
                {{on "click" (fn this.goTo i)}}
              ></button>
            {{/each}}
          </div>
        {{/if}}
      </div>
    {{/if}}
  </template>
}
