// var _ = require("lodash");

function injectScript(src) {

  return new Promise((resolve, reject) => {
    console.log("[injectScript] injecting " + src);
    var jsEl = document.createElement('script');
    jsEl.setAttribute('src', src);
    jsEl.async = true;
    jsEl.onload = () => {
      resolve();
      console.log("[injectScript] injected " + src);
    };
    document.body.appendChild(jsEl);
  });
}

function op_erosion_machine_setup() {
  console.log("[setup-erosion] starting");

  // escaped pattern to avoid replacement while deploying
  var hostNamePattern = "HOST__NAME".replace("__", "_");

  // const localHost = "http://localhost:8001";
  var localHost = "https://dev.eeefff.org";

  const TIMELINE_JSON_URL = 'HOST_NAME/data/outsourcing-paradise-parasite/v2/test/erosion-machine-timeline.json';

  // replace HOST NAME with localhost if the pattern is present
  var timelineUrl = TIMELINE_JSON_URL.replace(hostNamePattern, localHost);

  // insert root for elm engine
  document.body.insertAdjacentHTML('beforeend', '<div id="root"></div>');

  // insert timline url hidden input
  document.body.insertAdjacentHTML('beforeend', '<input type="hidden" id="timeline-url" value="' + timelineUrl + '">');

  //
  // inject js
  //
  var jsBaseUrl = 'HOST_NAME/js/'.replace(hostNamePattern, localHost);

  // injectScript(jsBaseUrl + 'op-erosion-machine-runtime-main.js');
  console.log("[setup-erosion] injecting js");
  injectScript(jsBaseUrl + 'op-erosion-machine-runtime-main.js')
    .then(() => {
      injectScript(jsBaseUrl + 'op-erosion-machine-vendors-main.js')
        .then(() => {
          return injectScript(jsBaseUrl + 'op-erosion-machine-main-chunk.js');
        })
        .then(() => {
          console.log("[setup-erosion] js injected");
        });
    });

  // document.body.insertAdjacentHTML('beforeend', '<script src="' + jsBaseUrl + 'op-erosion-machine-runtime-main.js' + '" async=""></script>');
  // document.body.insertAdjacentHTML('beforeend', '<script src="' + jsBaseUrl + 'op-erosion-machine-vendors-main.js' + '" async=""></script>');
  // document.body.insertAdjacentHTML('beforeend', '<script src="' + jsBaseUrl + 'op-erosion-machine-main-chunk.js' + '" async=""></script>');

  console.log("[setup-erosion] done");
}

//
// run setup when dom is ready
//
if (document.readyState === "interactive") {
  op_erosion_machine_setup();
} else {
  document.addEventListener("DOMContentLoaded", op_erosion_machine_setup);
}

// everything else goes after thate setup
