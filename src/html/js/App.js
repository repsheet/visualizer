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

function search() {
  const address = document.querySelector("#actor").value;
  window.location = "http://" + window.location.host + "/actor.html?address=" + address;
}

function stripPathname(pathname) {
  const parts = pathname.split("/")
  if (parts.length > 1) {
    return parts.slice(0, -1).join("/")
  } else {
    return pathname
  }
}

function getPath() {
  return window.location.protocol + "//" + window.location.host + stripPathname(window.location.pathname)
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

function fetchList(type, container, table) {
  fetch(getPath() + "/api/list?type=" + type)
    .then(response => response.json())
    .then(data => {
      if (!isEmpty(data.list)) {
	setCount(container, data.list.length)
	insertActors(table, data.list.slice(0,10))
      } else {
	setCount(container, 0)
      }
    });
}

function fetchListWithReason(type, table) {
  fetch(getPath() + "/api/list?type=" + type + "&include_reason=true")
    .then(response => response.json())
    .then(data => {
      insertActorsWithReason(table, data.list)
    });
}

function fetchActorStatus() {
  const address = getAddress()
  fetch(getPath() + "/api/actor?address=" + address)
    .then(response => response.json())
    .then(data => {
      if (!isEmpty(data.status)) {
	setActorStatus(address, data)
      }
    });
}

function fetchBlacklist() {
  const container = document.querySelector("#blacklist-count")
  const table = document.querySelector("#blacklist")
  fetchList("blacklist", container, table)
}

function fetchWhitelist() {
  const container = document.querySelector("#whitelist-count")
  const table = document.querySelector("#whitelist")
  fetchList("whitelist", container, table)
}

function fetchMarklist() {
  const container = document.querySelector("#marklist-count")
  const table = document.querySelector("#marklist")
  fetchList("mark", container, table)
}

function fetchBlacklistWithReason() {
  const table = document.querySelector("#blacklist")
  fetchListWithReason("blacklist", table)
}

function fetchWhitelistWithReason() {
  const table = document.querySelector("#whitelist")
  fetchListWithReason("whitelist", table)
}

function fetchMarklistWithReason() {
  const table = document.querySelector("#marklist")
  fetchListWithReason("mark", table)
}

function dashboard() {
  fetchBlacklist()
  fetchWhitelist()
  fetchMarklist()
}
