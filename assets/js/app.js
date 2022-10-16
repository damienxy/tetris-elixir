import '../css/app.css';

// Import deps with the dep name or local files with a relative path, for example:
//
//     import {Socket} from "phoenix"
//     import socket from "./socket"
//
import 'phoenix_html';
import { Socket } from 'phoenix';
import { LiveSocket } from 'phoenix_live_view';

window.addEventListener(
  'keydown',
  event =>
    ['ArrowUp', 'ArrowDown', 'ArrowLeft', 'ArrowRight', ' '].includes(
      event.key
    ) && event.preventDefault()
);

const getHighscoreFromLocalStorage = () =>
  (localStorage.getItem('highscore') || '')
    .split(',')
    .map(n => +n)
    .filter(Boolean);

const getLevelFromLocalStorage = () => +localStorage.getItem('level') || 1;

let Hooks = {};

Hooks.Highscore = {
  mounted() {
    this.pushEvent('loadHighscore', {
      highscore: getHighscoreFromLocalStorage()
    });

    this.handleEvent('updateHighscore', ({ score }) => {
      const currentHighscore = getHighscoreFromLocalStorage();
      const newHighscore = [...new Set([...currentHighscore, score])]
        .filter(Boolean)
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

Hooks.Level = {
  mounted() {
    this.pushEvent('loadLevel', {
      level: getLevelFromLocalStorage()
    });

    this.handleEvent('updateLevel', ({ level }) => {
      const newLevel = +level;
      localStorage.setItem('level', newLevel);
      this.pushEvent('loadLevel', {
        level: newLevel
      });
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

// connect if there are any LiveViews on the page
liveSocket.connect();

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket;
