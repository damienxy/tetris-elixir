// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import '../css/app.scss';

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import deps with the dep name or local files with a relative path, for example:
//
//     import {Socket} from "phoenix"
//     import socket from "./socket"
//
import 'phoenix_html';
import { Socket } from 'phoenix';
import topbar from 'topbar';
import { LiveSocket } from 'phoenix_live_view';

window.addEventListener(
  'keydown',
  event =>
    ['ArrowUp', 'ArrowDown', 'ArrowLeft', 'ArrowRight', ' '].includes(
      event.key
    ) && event.preventDefault()
);

const getHighscoreFromLocalStorage = () =>
  localStorage
    .getItem('highscore')
    .split(',')
    .map(n => +n);

let Hooks = {};

Hooks.Highscore = {
  mounted() {
    this.pushEvent('loadHighscore', {
      highscore: getHighscoreFromLocalStorage()
    });

    this.handleEvent('updateHighscore', ({ score }) => {
      const currentHighscore = getHighscoreFromLocalStorage();
      const newHighscore = [...new Set([...currentHighscore, score])]
        .filter(n => n > 0)
        .sort((a, b) => b - a)
        .slice(0, 5);
      localStorage.setItem('highscore', newHighscore);
      this.pushEvent('loadHighscore', {
        highscore: newHighscore
      });
    });
  },
  reconnected() {
    this.pushEvent('loadHighscore', {
      highscore: getHighscoreFromLocalStorage()
    });
  }
};

let csrfToken = document
  .querySelector("meta[name='csrf-token']")
  .getAttribute('content');
let liveSocket = new LiveSocket('/live', Socket, {
  params: { _csrf_token: csrfToken },
  hooks: Hooks
});

// Show progress bar on live navigation and form submits
topbar.config({ barColors: { 0: '#29d' }, shadowColor: 'rgba(0, 0, 0, .3)' });
window.addEventListener('phx:page-loading-start', info => topbar.show());
window.addEventListener('phx:page-loading-stop', info => topbar.hide());

// connect if there are any LiveViews on the page
liveSocket.connect();

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket;
