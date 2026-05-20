// Connector for the `discovery-list-container-top` plugin outlet — the hero
// slider (.sktvd-slider), block E1 of HOMEPAGE_SPEC.
//
// .gjs glimmer component: @tracked state + native handlers. Slides are
// authored in the `slides` theme setting (type: objects). Auto-rotates every
// 7s, pauses on hover and resumes on leave (spec §5.E1); a progress bar
// tracks the 7s cycle.

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
  @tracked paused = false;
  // Bumped whenever the 7s progress bar should restart (slide change / resume).
  @tracked cycle = 0;

  constructor() {
    super(...arguments);
    this.#start();
  }

  willDestroy() {
    super.willDestroy(...arguments);
    this.#stop();
  }

  get enabled() {
    return settings.enable_slider && this.slides.length > 0;
  }

  get current() {
    return this.slides[this.index];
  }

  get multiple() {
    return this.slides.length > 1;
  }

  // Keyed {{#each}} over this recreates the progress fill so its CSS
  // animation restarts from 0.
  get progressKey() {
    return [this.cycle];
  }

  #start() {
    if (this.enabled && this.multiple && !this._timer) {
      this._timer = setInterval(() => {
        this.index = (this.index + 1) % this.slides.length;
        this.cycle++;
      }, ROTATE_MS);
    }
  }

  #stop() {
    if (this._timer) {
      clearInterval(this._timer);
      this._timer = null;
    }
  }

  #restart() {
    this.#stop();
    if (!this.paused) {
      this.#start();
    }
  }

  @action
  goTo(i) {
    this.index = i;
    this.cycle++;
    this.#restart();
  }

  @action
  step(delta) {
    const n = this.slides.length;
    this.index = (this.index + delta + n) % n;
    this.cycle++;
    this.#restart();
  }

  @action
  pause() {
    this.paused = true;
    this.#stop();
  }

  @action
  resume() {
    this.paused = false;
    this.cycle++;
    this.#start();
  }

  <template>
    {{#if this.enabled}}
      <div
        class="sktvd-slider"
        {{on "mouseenter" this.pause}}
        {{on "mouseleave" this.resume}}
      >
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

        {{#if this.multiple}}
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

          <div class="sktvd-slider-progress">
            {{#each this.progressKey key="@identity" as |k|}}
              <div
                class="sktvd-slider-progress-fill {{if this.paused 'is-paused'}}"
              ></div>
            {{/each}}
          </div>
        {{/if}}
      </div>
    {{/if}}
  </template>
}
