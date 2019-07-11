function getAddress() {
  const params = new URLSearchParams(window.location.search)
  return params.get("address")
}

function isEmpty(obj) {
  for(var key in obj) {
    if(obj.hasOwnProperty(key)) {
      return false;
    }
  }

  return true;
}

function setActorStatus(address, data) {
  const status = data[0]
  const reason = data[1]

  document.querySelector("#address-container").innerHTML = address
  document.querySelector("#actor-status-container").innerHTML = status
  document.querySelector("#actor-reason-container").innerHTML = reason
}

function setBlacklistCount(count) {
  if (count === undefined) {
    count = 0;
  }

  document.querySelector("#blacklist-count").innerHTML = count
}

function setWhitelistCount(count) {
  if (count === undefined) {
    count = 0;
  }

  document.querySelector("#whitelist-count").innerHTML = count
}

function setMarklistCount(count) {
  if (count === undefined) {
    count = 0;
  }

  document.querySelector("#marklist-count").innerHTML = count
}

function setBlacklistColumn(actors) {
  const table = document.querySelector("#blacklist")
  actors.forEach(actor => listItem(table, actor))
}

function setBlacklistPage(actors) {
  const table = document.querySelector("#blacklist")
  for (let [address, reason] of Object.entries(actors)) {
    listItemWithReason(table, address, reason)
  }
}

function setWhitelistColumn(actors) {
  const table = document.querySelector("#whitelist")
  actors.forEach(actor => listItem(table, actor))
}

function setWhitelistPage(actors) {
  const table = document.querySelector("#whitelist")
  for (let [address, reason] of Object.entries(actors)) {
    listItemWithReason(table, address, reason)
  }
}

function setMarklistColumn(actors) {
  const table = document.querySelector("#marklist")
  actors.forEach(actor => listItem(table, actor))
}

function setMarklistPage(actors) {
  const table = document.querySelector("#marklist")
  for (let [address, reason] of Object.entries(actors)) {
    listItemWithReason(table, address, reason)
  }
}

function listItem(table, address) {
  let row = table.insertRow(-1)
  let ip = row.insertCell(0)
  let linkCell = row.insertCell(1)
  ip.appendChild(document.createTextNode(address))
  let link = document.createElement("a")
  let chevron = document.createElement("i")
  linkCell.style.textAlign = "right";
  link.setAttribute("href", "actor.html?address=" + address)
  link.className = "btn btn-xs btn-tertiary"
  chevron.className = "fa fa-chevron-right"
  link.appendChild(document.createTextNode("View  "))
  link.appendChild(chevron)
  linkCell.appendChild(link)
}

function listItemWithReason(table, address, reason) {
  let row = table.insertRow(-1)
  let ip = row.insertCell(0)
  let reasonCell = row.insertCell(1)
  let linkCell = row.insertCell(2)
  linkCell.style.textAlign = "right";
  ip.appendChild(document.createTextNode(address))
  reasonCell.appendChild(document.createTextNode(reason))
  let link = document.createElement("a")
  let chevron = document.createElement("i")
  link.setAttribute("href", "actor.html?address=" + address)
  link.className = "btn btn-xs btn-tertiary"
  chevron.className = "fa fa-chevron-right"
  link.appendChild(document.createTextNode("View  "))
  link.appendChild(chevron)
  linkCell.appendChild(link)
}

function fetchBlacklist() {
  fetch("http://localhost:8888/api/blacklist")
    .then(response => response.json())
    .then(data => {
      if (!isEmpty(data.blacklist)) {
	setBlacklistCount(data.blacklist.length)
	setBlacklistColumn(data.blacklist.slice(0,10))
      } else {
	setBlacklistCount(0)
      }
    });
}

function fetchBlacklistWithReason() {
  fetch("http://localhost:8888/api/blacklist_with_reason")
    .then(response => response.json())
    .then(data => {
      setBlacklistPage(data.blacklist)
    });
}

function fetchWhitelist() {
  fetch("http://localhost:8888/api/whitelist")
    .then(response => response.json())
    .then(data => {
      if (!isEmpty(data.whitelist)) {
	setWhitelistCount(data.whitelist.length)
	setWhitelistColumn(data.whitelist.slice(0,10))
      } else {
	setWhitelistCount(0)
      }
    });
}

function fetchWhitelistWithReason() {
  fetch("http://localhost:8888/api/whitelist_with_reason")
    .then(response => response.json())
    .then(data => {
      setWhitelistPage(data.whitelist)
    });
}

function fetchMarklist() {
  fetch("http://localhost:8888/api/marklist")
    .then(response => response.json())
    .then(data => {
      if (!isEmpty(data.marklist)) {
	setMarklistCount(data.marklist.length)
	setMarklistColumn(data.marklist.slice(0,10))
      } else {
	setMarklistCount(0)
      }
    });
}

function fetchMarklistWithReason() {
  fetch("http://localhost:8888/api/marklist_with_reason")
    .then(response => response.json())
    .then(data => {
      setMarklistPage(data.marklist)
    });
}

function fetchActorStatus() {
  const address = getAddress()
  fetch("http://localhost:8888/api/actor?address=" + address)
    .then(response => response.json())
    .then(data => {
      if (!isEmpty(data.status)) {
	setActorStatus(address, data.status)
      }
    });
}

function dashboard() {
  fetchBlacklist()
  fetchWhitelist()
  fetchMarklist()
}
