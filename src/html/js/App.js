function setBlacklistCount(count) {
  document.querySelector("#blacklist-count").innerHTML = count
}

function setWhitelistCount(count) {
  document.querySelector("#whitelist-count").innerHTML = count
}

function setMarklistCount(count) {
  document.querySelector("#marklist-count").innerHTML = count
}

function setBlacklistColumn(actors) {
  const table = document.querySelector("#blacklist")
  actors.forEach(actor => listItem(table, actor))
}

function setWhitelistColumn(actors) {
  const table = document.querySelector("#whitelist")
  actors.forEach(actor => listItem(table, actor))
}

function setMarklistColumn(actors) {
  const table = document.querySelector("#marklist")
  actors.forEach(actor => listItem(table, actor))
}

function listItem(table, address) {
  let row = table.insertRow(-1)
  let ip = row.insertCell(0)
  let linkCell = row.insertCell(1)
  ip.appendChild(document.createTextNode(address))
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
      setBlacklistCount(data.blacklist.length)
      setBlacklistColumn(data.blacklist.slice(0,10))
    });
}

function fetchWhitelist() {
  fetch("http://localhost:8888/api/whitelist")
    .then(response => response.json())
    .then(data => {
      setWhitelistCount(data.whitelist.length)
      setWhitelistColumn(data.whitelist.slice(0,10))
    });
}

function fetchMarklist() {
  fetch("http://localhost:8888/api/marklist")
    .then(response => response.json())
    .then(data => {
      setMarklistCount(data.marklist.length)
      setMarklistColumn(data.marklist.slice(0,10))
    });
}

function dashboard() {
  fetchBlacklist()
  fetchWhitelist()
  fetchMarklist()
}
