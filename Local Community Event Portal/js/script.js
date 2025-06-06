// 1. Basics & Setup
console.log("Welcome to the Community Portal");
window.onload = function() {
  alert("Page is fully loaded!");
};

// 2. Example Event Data
let allEvents = [
  { name: "Music Fest", date: "2025-06-18", category: "Music", seats: 2 },
  { name: "Tech Talk", date: "2025-07-01", category: "Tech", seats: 5 },
  { name: "Cooking Workshop", date: "2025-05-25", category: "Food", seats: 3 },
  { name: "Jazz Night", date: "2025-08-15", category: "Music", seats: 0 }
];

// 3. DOM References
const eventsDiv = document.querySelector("#events");
const eventSelect = document.getElementById("eventSelect");
const categoryFilter = document.getElementById("categoryFilter");
const quickSearch = document.getElementById("quickSearch");

// 4. Render Event Options in Form
function renderEventOptions(eventsList) {
  eventSelect.innerHTML = `<option value="">Select an Event</option>`;
  eventsList.forEach(event => {
    if (new Date(event.date) > new Date() && event.seats > 0)
      eventSelect.innerHTML += `<option value="${event.name}">${event.name}</option>`;
  });
}
renderEventOptions(allEvents);

// 5. Render Event Cards
function renderEvents(eventsList) {
  eventsDiv.innerHTML = "";
  eventsList.forEach(event => {
    // Only display future events with seats
    if (new Date(event.date) > new Date() && event.seats > 0) {
      const card = document.createElement("div");
      card.className = "eventCard";
      card.innerHTML = `
        <h4>${event.name}</h4>
        <p>Category: ${event.category}</p>
        <p>Date: ${event.date}</p>
        <p>Seats Left: ${event.seats}</p>
        <button onclick="registerFromCard('${event.name}')">Register</button>
      `;
      eventsDiv.appendChild(card);
    }
  });
}
renderEvents(allEvents);

// 6. Registration from Event Card
window.registerFromCard = function(eventName) {
  eventSelect.value = eventName;
  document.getElementById("registerForm").scrollIntoView({ behavior: "smooth" });
}

// 7. Register Form Handler
document.getElementById("registerForm").onsubmit = function(e) {
  e.preventDefault();
  const name = this.elements.name.value.trim();
  const email = this.elements.email.value.trim();
  const eventName = this.elements.event.value;

  if (!name || !email || !eventName) {
    document.getElementById("formError").textContent = "Please fill all fields";
    return;
  }

  // Find event object
  const eventObj = allEvents.find(ev => ev.name === eventName);
  if (eventObj && eventObj.seats > 0) {
    eventObj.seats--;
    renderEvents(filteredAndSearchedEvents());
    renderEventOptions(filteredAndSearchedEvents());
    alert(`Registered for ${eventObj.name}!`);
    document.getElementById("formError").textContent = "";
    this.reset();
  } else {
    document.getElementById("formError").textContent = "Event is full or unavailable!";
  }
};

// 8. Filter by Category
categoryFilter.onchange = function() {
  renderEvents(filteredAndSearchedEvents());
  renderEventOptions(filteredAndSearchedEvents());
};

// 9. Quick Search by Name
quickSearch.onkeydown = function() {
  setTimeout(() => {
    renderEvents(filteredAndSearchedEvents());
    renderEventOptions(filteredAndSearchedEvents());
  }, 100); // debounce
};

// 10. Filtering and Searching Combined
function filteredAndSearchedEvents() {
  let filtered = [...allEvents];
  const category = categoryFilter.value;
  const search = quickSearch.value.trim().toLowerCase();
  if (category)
    filtered = filtered.filter(ev => ev.category === category);
  if (search)
    filtered = filtered.filter(ev => ev.name.toLowerCase().includes(search));
  return filtered;
}

// 11. Example Async Fetch (simulated)
async function fetchEventsFromAPI() {
  // Simulating network call with Promise/async
  return new Promise(resolve => {
    setTimeout(() => resolve(allEvents), 500);
  });
}
fetchEventsFromAPI().then(events => console.log("Fetched events:", events));

// 12. Debug Example
console.log("Events loaded:", allEvents);

// 13. Modern Features Example
const [firstEvent, ...rest] = allEvents;
console.log("First event:", firstEvent);