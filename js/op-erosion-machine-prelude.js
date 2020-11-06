// var _ = require("lodash");

function op_erosion_machine_setup() {
  // escaped pattern to avoid replacement while deploying
  var hostNamePattern = "HOST__NAME".replace("__", "_");

  // const localHost = "http://localhost:8001";
  var localHost = "https://dev.eeefff.org";

  const TIMELINE_JSON_URL = 'HOST_NAME/data/outsourcing-paradise-parasite/v2/test/erosion-machine-timeline.json';

  // replace HOST NAME with localhost if the pattern is present
  var timelineUrl = TIMELINE_JSON_URL.replace(hostNamePattern, localHost);

  // insert root for elm engine
  document.body.insertAdjacentHTML('afterbegin', '<div id="root"></div>');

  // insert timline url hidden input
  document.body.insertAdjacentHTML('afterbegin', '<input type="hidden" id="timeline-url" value="' + timelineUrl + '">');
}

op_erosion_machine_setup();

// everything else goes after thate setup
