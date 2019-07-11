function isEmpty(obj) {
  for(var key in obj) {
    if(obj.hasOwnProperty(key)) {
      return false;
    }
  }

  return true;
}

function getAddress() {
  const params = new URLSearchParams(window.location.search)
  return params.get("address")
}

function setActorStatus(address, data) {
  const status = data.status[0]
  const reason = data.status[1]

  document.querySelector("#address-container").innerHTML = address
  document.querySelector("#actor-status-container").innerHTML = status
  document.querySelector("#actor-reason-container").innerHTML = reason
  document.querySelector("#request-count-container").innerHTML = data.request_count

  addRequests(data.requests)
}

function setCount(container, count) {
  if (count === undefined) {
    count = 0;
  }

  container.innerHTML = count
}

function insertActors(table, actors) {
  actors.forEach(actor => insertTableRow(table, actor))
}

function insertActorsWithReason(table, actors) {
  for (let [address, reason] of Object.entries(actors)) {
    insertTableRowWithReason(table, address, reason)
  }
}

function createIpCell(row, address, position) {
  const ip = row.insertCell(position)
  ip.appendChild(document.createTextNode(address))
}

function createChevron() {
  const chevron = document.createElement("i")
  chevron.className = "fa fa-chevron-right"
  return chevron
}

function createLink(address) {
  const link = document.createElement("a")
  link.setAttribute("href", "actor.html?address=" + address)
  link.className = "btn btn-xs btn-tertiary"
  link.appendChild(document.createTextNode("View  "))
  link.appendChild(createChevron())
  return link
}

function createLinkCell(row, address, position) {
  const linkCell = row.insertCell(position)
  linkCell.style.textAlign = "right";
  linkCell.appendChild(createLink(address))
  return linkCell
}

function createReasonCell(row, reason, position) {
  const reasonCell = row.insertCell(position)
  reasonCell.appendChild(document.createTextNode(reason))
}

function insertTableRow(table, address) {
  const row = table.insertRow(-1)
  createIpCell(row, address, 0)
  createLinkCell(row, address, 1)
}

function insertTableRowWithReason(table, address, reason) {
  const row = table.insertRow(-1)
  createIpCell(row, address, 0)
  createReasonCell(row, reason, 1)
  createLinkCell(row, address, 2)
}

function addRequests(requests) {
  const container = document.querySelector("#activity-container")
  const ul = document.createElement("ul")
  ul.className = "requests"
  requests.forEach(request => {
    const li = document.createElement("li")
    li.appendChild(document.createTextNode(request))
    ul.appendChild(li)
  });
  container.appendChild(ul)
}

function fetchBlacklist() {
  const container = document.querySelector("#blacklist-count")
  const table = document.querySelector("#blacklist")
  fetch("http://localhost:8888/api/blacklist")
    .then(response => response.json())
    .then(data => {
      if (!isEmpty(data.blacklist)) {
	setCount(container, data.blacklist.length)
	insertActors(table, data.blacklist.slice(0,10))
      } else {
	setCount(container, 0)
      }
    });
}

function fetchWhitelist() {
  const container = document.querySelector("#whitelist-count")
  const table = document.querySelector("#whitelist")
  fetch("http://localhost:8888/api/whitelist")
    .then(response => response.json())
    .then(data => {
      if (!isEmpty(data.whitelist)) {
	setCount(container, data.whitelist.length)
	insertActors(table, data.whitelist.slice(0,10))
      } else {
	setCount(container, 0)
      }
    });
}

function fetchMarklist() {
  const container = document.querySelector("#marklist-count")
  const table = document.querySelector("#marklist")
  fetch("http://localhost:8888/api/marklist")
    .then(response => response.json())
    .then(data => {
      if (!isEmpty(data.marklist)) {
	setCount(container, data.marklist.length)
	insertActors(table, data.marklist.slice(0,10))
      } else {
	setCount(container, 0)
      }
    });
}

function fetchBlacklistWithReason() {
  const table = document.querySelector("#blacklist")
  fetch("http://localhost:8888/api/blacklist_with_reason")
    .then(response => response.json())
    .then(data => {
      insertActorsWithReason(table, data.blacklist)
    });
}

function fetchWhitelistWithReason() {
    const table = document.querySelector("#whitelist")
  fetch("http://localhost:8888/api/whitelist_with_reason")
    .then(response => response.json())
    .then(data => {
      insertActorsWithReason(table, data.whitelist)
    });
}

function fetchMarklistWithReason() {
  const table = document.querySelector("#marklist")
  fetch("http://localhost:8888/api/marklist_with_reason")
    .then(response => response.json())
    .then(data => {
      insertActorsWithReason(table, data.marklist)
    });
}

function fetchActorStatus() {
  const address = getAddress()
  fetch("http://localhost:8888/api/actor?address=" + address)
    .then(response => response.json())
    .then(data => {
      if (!isEmpty(data.status)) {
	setActorStatus(address, data)
      }
    });
}

function dashboard() {
  fetchBlacklist()
  fetchWhitelist()
  fetchMarklist()
}
