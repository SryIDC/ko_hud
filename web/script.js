const locationWindow = document.getElementById("location");
const statusWindow = document.getElementById("status");
const speedometerWindow = document.getElementById("speedometer");
const bankBalance = document.getElementById("bank-balance");
const cashBalance = document.getElementById("cash-balance");
const moneyDisplay = document.getElementById("money-display");
const bankAmount = document.getElementById("bank-amount");
const cashAmount = document.getElementById("cash-amount");
const jobDisplay = document.getElementById("job-display");
const playerIdDisplay = document.getElementById("player-id");

const arrow = document.getElementById("arrow");
const direction = document.getElementById("direction");
const zipcode = document.getElementById("zipcode");
const distance = document.getElementById("distance");
const streetname = document.getElementById("streetname");
const zone = document.getElementById("zone");

const thirstcontainer = document.getElementById("thirstcontainer");
const foodcontainer = document.getElementById("foodcontainer");
const armorcontainer = document.getElementById("armorcontainer");
const oxygencontainer = document.getElementById("oxygencontainer");
const stresscontainer = document.getElementById("stresscontainer");

const healthtext = document.getElementById("healthtext");
const armortext = document.getElementById("armortext");
const thirsttext = document.getElementById("thirsttext");
const foodtext = document.getElementById("foodtext");
const oxygentext = document.getElementById("oxygentext");
const stresstext = document.getElementById("stresstext");
const healthbar = document.getElementById("health");
const armorbar = document.getElementById("armor");
const thirstbar = document.getElementById("thirst");
const foodbar = document.getElementById("food");
const oxygenbar = document.getElementById("oxygen");
const stressbar = document.getElementById("stress");
const voice = document.getElementById("voice");

const speed = document.getElementById("speed-svg");
const speedtextkm = document.getElementById("speedtextkm");
const speedtextmiles = document.getElementById("speedtextmiles");
const fuel = document.getElementById("fuel-svg");
const fuel_path = document.getElementById("fuel-path");
const fuel_icon = document.getElementById("fuel-icon");

const seatbelt = document.getElementById("seatbelt");
const engine = document.getElementById("engine");
const highbeams = document.getElementById("beam");

let left = 0;

// Track previous money values for change detection
let previousBankBalance = 0;
let previousCashBalance = 0;

// Function to animate money changes
function animateMoneyChange(element, newValue, oldValue) {
  const difference = newValue - oldValue;
  
  if (difference > 0) {
    // Money increased
    element.classList.remove('money-decrease', 'money-pulse');
    element.classList.add('money-increase');
    
    // Show positive indicator
    showChangeIndicator(element, `+$${Math.abs(difference).toLocaleString()}`, 'positive');
  } else if (difference < 0) {
    // Money decreased
    element.classList.remove('money-increase', 'money-pulse');
    element.classList.add('money-decrease');
    
    // Show negative indicator
    showChangeIndicator(element, `-$${Math.abs(difference).toLocaleString()}`, 'negative');
  } else {
    // Same value, just pulse
    element.classList.remove('money-increase', 'money-decrease');
    element.classList.add('money-pulse');
  }
  
  // Remove animation classes after animation completes
  setTimeout(() => {
    element.classList.remove('money-increase', 'money-decrease', 'money-pulse');
  }, 800);
}

// Function to show change indicator
function showChangeIndicator(element, text, type) {
  // Remove existing indicator
  const existingIndicator = element.querySelector('.money-change-indicator');
  if (existingIndicator) {
    existingIndicator.remove();
  }
  
  // Create new indicator
  const indicator = document.createElement('span');
  indicator.className = `money-change-indicator ${type}`;
  indicator.textContent = text;
  element.style.position = 'relative';
  element.appendChild(indicator);
  
  // Show indicator
  setTimeout(() => {
    indicator.classList.add('show');
  }, 100);
  
  // Hide and remove indicator
  setTimeout(() => {
    indicator.classList.remove('show');
    setTimeout(() => {
      if (indicator.parentNode) {
        indicator.remove();
      }
    }, 300);
  }, 2000);
}

window.addEventListener("message", (event) => {
  // Handle overall HUD visibility (for map/pause menu)
  if (event.data.component == "hud") {
    document.body.style.display = event.data.visible ? "block" : "none";
    return;
  }

  if (event.data.component == "position") {
    if (event.data.visible == null) {
      left = 1;
      locationWindow.style.opacity = 1;
      arrow.style.rotate = -event.data.heading + "deg";

      direction.innerText = event.data.direction;
      zipcode.innerText = event.data.postal;
      distance.innerText = event.data.distance;
      streetname.innerText = event.data.street;
      zone.innerText = event.data.zone;
    } else {
      left = 0;
      locationWindow.style.opacity = 0;
    }
  }

  if (event.data.component == "status") {
    if (event.data.visible == null) {
      statusWindow.style.opacity = 1;
      if (event.data.hungerVisible) {
        foodcontainer.style.display = "block";
      } else {
        foodcontainer.style.display = "none";
      }
      if (event.data.thirstVisible) {
        thirstcontainer.style.display = "block";
      } else {
        thirstcontainer.style.display = "none";
      }
      if (event.data.voiceVisible) {
        voice.style.display = "block";
      } else {
        voice.style.display = "none";
      }
      if (event.data.stressVisible) {
        stresscontainer.style.display = "block";
      } else {
        stresscontainer.style.display = "none";
      }

      if (event.data.voiceTalking == true) {
        if (voice.classList.contains("disabled")) {
          voice.classList.remove("disabled");
        }
      } else {
        if (!voice.classList.contains("disabled")) {
          voice.classList.add("disabled");
        }
      }

      voice.src = event.data.voiceType;

      let health;
      if (event.data.health <= 0) {
        // Player is dead
        health = 0;
      } else {
        // Player is alive, calculate percentage
        health = Math.round(((event.data.health - 100) * 100) / (event.data.maxhealth - 100));
        if (health > 100) {
          health = 100;
        }
        if (health < 0) {
          health = 0;
        }
      }
      let armor = Math.round((event.data.armor * 100) / 100);
      if (event.data.armorVisible && armor > 0) {
        armorcontainer.style.display = "block";
      } else {
        armorcontainer.style.display = "none";
      }
      let thirst = Math.round((event.data.thirst * 100) / 100);
      let food = Math.round((event.data.hunger * 100) / 100);
      let stress = Math.round((event.data.stress * 100) / 100);
      if (stress < 0) {
        stress = 0;
      }
      if (stress > 100) {
        stress = 100;
      }
      
      // Debug: Log stress value
      // if (Math.random() < 0.1) { // 10% chance to log to avoid spam
      //   console.log("Stress received:", event.data.stress, "calculated:", stress);
      // }

      let oxygen = Math.round((event.data.oxygen * 100) / 40);

      if (event.data.framework == "qbcore" || event.data.framework == "esx") {
        oxygen = Math.round((event.data.oxygen * 100) / 10);
      }

      if (oxygen < 0) {
        oxygen = 0;
      }

      if (oxygen != 100) {
        oxygencontainer.style.display = "block";
      } else {
        oxygencontainer.style.display = "none";
      }

      healthtext.innerText = health + "%";
      healthbar.style.width = (health * 150) / 100 + "px";
      healthbar.style.setProperty("--size", 150 - (health * 150) / 100 + "px");
      armortext.innerText = armor + "%";
      armorbar.style.width = (armor * 150) / 100 + "px";
      armorbar.style.setProperty("--size", 150 - (armor * 150) / 100 + "px");

      thirsttext.innerText = thirst + "%";
      thirstbar.style.width = (thirst * 150) / 100 + "px";
      thirstbar.style.setProperty("--size", 150 - (thirst * 150) / 100 + "px");

      foodtext.innerText = food + "%";
      foodbar.style.width = (food * 150) / 100 + "px";
      foodbar.style.setProperty("--size", 150 - (food * 150) / 100 + "px");

      oxygentext.innerText = oxygen + "%";
      oxygenbar.style.width = (oxygen * 150) / 100 + "px";
      oxygenbar.style.setProperty("--size", 150 - (oxygen * 150) / 100 + "px");

      stresstext.innerText = stress + "%";
      stressbar.style.width = (stress * 150) / 100 + "px";
      stressbar.style.setProperty("--size", 150 - (stress * 150) / 100 + "px");
    } else {
      if (event.data.visible == true) {
        statusWindow.style.opacity = 1;
      } else {
        statusWindow.style.opacity = 0;
      }
    }
  }

  if (event.data.component == "speedometer") {
    if (event.data.visible == null) {
      if (event.data.seatbeltVisible) {
        seatbelt.style.display = "block";
      } else {
        seatbelt.style.display = "none";
      }
      if (event.data.fuelVisible) {
        speedometerWindow.style.marginLeft = "0px";
        fuel.style.display = "block";
        fuel_path.style.display = "block";
        fuel_icon.style.display = "block";
      } else {
        speedometerWindow.style.marginLeft = "10px";
        fuel.style.display = "none";
        fuel_path.style.display = "none";
        fuel_icon.style.display = "none";
      }
      speedometerWindow.style.opacity = 1;
      let percent_speed = (event.data.speed * 100) / (event.data.maxspeed + 50);
      let percent_fuel = (event.data.fuel * 100) / event.data.maxfuel;
      if (event.data.framework == "qbcore") {
        percent_fuel = event.data.fuel;
      }
      setDashedGaugeValue(speed, percent_speed, 219.911485751);
      setDashedGaugeValue(fuel, percent_fuel, 87.9645943005);
      speedtextkm.innerText = Math.round(event.data.speed);
      speedtextmiles.innerText = Math.round(event.data.speed);

      if (event.data.speed < 35) {
        speed.classList.remove('moderate-speed', 'high-speed', 'dangerous-speed');
        speed.classList.add('safe-speed');
      } else if (event.data.speed < 75) {
        speed.classList.remove('safe-speed', 'high-speed', 'dangerous-speed');
        speed.classList.add('moderate-speed');
      } else if (event.data.speed < 120) {
        speed.classList.remove('safe-speed', 'moderate-speed', 'dangerous-speed');
        speed.classList.add('high-speed');
      } else {
        speed.classList.remove('safe-speed', 'moderate-speed', 'high-speed');
        speed.classList.add('dangerous-speed');
      }

      if (percent_fuel >= 30) {
        fuel.classList.remove('low-fuel', 'critical-fuel');
        fuel.classList.add('normal-fuel');
      } else if (percent_fuel >= 15) {
        fuel.classList.remove('normal-fuel', 'critical-fuel');
        fuel.classList.add('low-fuel');
      } else {
        fuel.classList.remove('normal-fuel', 'low-fuel');
        fuel.classList.add('critical-fuel');
      }


      if (event.data.iselectric == true) {
        fuel_icon.src = "battery.png";
      } else {
        fuel_icon.src = "gas.png";
      }

      if (event.data.useMiles == true) {
        speedtextkm.style.display = "none";
        speedtextmiles.style.display = "block";
      } else {
        speedtextkm.style.display = "block";
        speedtextmiles.style.display = "none";
      }

      if (event.data.hasmotor == true) {
        highbeams.style.display = "block";
        engine.style.display = "block";
        speedometerWindow.style.marginLeft = "0px";
        speedometerWindow.style.marginBottom = "0px";
      } else {
        highbeams.style.display = "none";
        engine.style.display = "none";
        seatbelt.style.display = "none";
        fuel.style.display = "none";
        fuel_path.style.display = "none";
        fuel_icon.style.display = "none";
        speedometerWindow.style.marginLeft = "10px";
        speedometerWindow.style.marginBottom = "-10px";
      }

      // Highbeams state management
      if (event.data.highbeams === 1) {
        highbeams.classList.remove("disabled");
      } else {
        highbeams.classList.add("disabled");
      }

      // Engine state management
      if (event.data.engine === 1) {
        engine.classList.remove("disabled");
      } else {
        engine.classList.add("disabled");
      }


      // Seatbelt state management
      if (event.data.seatbelt === true) {
        seatbelt.classList.remove("disabled");
      } else {
        seatbelt.classList.add("disabled");
      }
    } else {
      speedometerWindow.style.opacity = 0;
    }
  }

  if (event.data.component == "bank") {
    if (event.data.visible !== false) {
      moneyDisplay.style.opacity = 1;
      moneyDisplay.classList.add("visible");
      
      // Get the new balance
      const newBankBalance = event.data.balance;
      
      // Animate money change if value is different
      if (newBankBalance !== previousBankBalance) {
        animateMoneyChange(bankAmount, newBankBalance, previousBankBalance);
      }
      
      // Format bank balance with commas
      const formattedBalance = new Intl.NumberFormat('en-US').format(newBankBalance);
      bankAmount.textContent = `$${formattedBalance}`;
      
      // Store new value for next comparison
      previousBankBalance = newBankBalance;
    } else {
      // Only hide if both bank and cash are disabled
      if (!cashAmount.textContent || cashAmount.textContent === '$0') {
        moneyDisplay.style.opacity = 0;
        moneyDisplay.classList.remove("visible");
      }
    }
  }

  if (event.data.component == "cash") {
    if (event.data.visible !== false) {
      moneyDisplay.style.opacity = 1;
      moneyDisplay.classList.add("visible");
      
      // Get the new balance
      const newCashBalance = event.data.balance;
      
      // Animate money change if value is different
      if (newCashBalance !== previousCashBalance) {
        animateMoneyChange(cashAmount, newCashBalance, previousCashBalance);
      }
      
      // Format cash balance with commas
      const formattedCash = new Intl.NumberFormat('en-US').format(newCashBalance);
      cashAmount.textContent = `$${formattedCash}`;
      
      // Store new value for next comparison
      previousCashBalance = newCashBalance;
    } else {
      // Only hide if both bank and cash are disabled
      if (!bankAmount.textContent || bankAmount.textContent === '$0') {
        moneyDisplay.style.opacity = 0;
        moneyDisplay.classList.remove("visible");
      }
    }
  }

  if (event.data.component == "job") {
    if (event.data.visible !== false) {
      jobDisplay.style.opacity = 1;
      jobDisplay.classList.add("visible");
      
      // Format job as "Job Name - Job Grade"
      const jobText = `${event.data.jobName || 'Unemployed'} - ${event.data.jobGrade || 'Citizen'}`;
      jobDisplay.textContent = jobText;
      
      // Add special styling for off-duty status
      if (event.data.jobGrade && event.data.jobGrade.toLowerCase() === 'off duty') {
        jobDisplay.classList.add('off-duty');
      } else {
        jobDisplay.classList.remove('off-duty');
      }
    } else {
      jobDisplay.style.opacity = 0;
      jobDisplay.classList.remove("visible");
    }
  }

  if (event.data.component == "playerId") {
    if (event.data.visible !== false) {
      playerIdDisplay.style.opacity = 1;
      playerIdDisplay.classList.add("visible");
      
      // Display player ID
      const playerId = event.data.playerId || 0;
      playerIdDisplay.textContent = `ID: ${playerId}`;
    } else {
      playerIdDisplay.style.opacity = 0;
      playerIdDisplay.classList.remove("visible");
    }
  }

  if (event.data.component == "configuration") {
    locationWindow.style.left = event.data.locationleft + "px";
    locationWindow.style.bottom = event.data.locationbottom + "px";
    statusWindow.style.right = event.data.statusright + "px";
    statusWindow.style.bottom = event.data.statusbottom + "px";
    speedometerWindow.style.bottom = event.data.speedometerbottom + "px";
    moneyDisplay.style.top = event.data.banktop + "px";
    moneyDisplay.style.right = event.data.bankright + "px";
    jobDisplay.style.top = event.data.jobtop + "px";
    jobDisplay.style.right = event.data.jobright + "px";
  // No need to set playerIdDisplay position, it's now inline with the voice icon
  }
});

function setDashedGaugeValue(gaugeDOMElement, percentage, arcLength) {
  const emptyDashLength = 500;
  const filledArcLength = arcLength * (percentage / 100);
  gaugeDOMElement.style.strokeDasharray = `${filledArcLength} ${emptyDashLength}`;
  gaugeDOMElement.style.strokeDashoffset = filledArcLength;
}

setDashedGaugeValue(speed, 0, 219.911485751);
setDashedGaugeValue(fuel, 0, 87.9645943005);

// Initialize seatbelt and other icons to disabled state by default
if (seatbelt) {
  seatbelt.classList.add("disabled");
}
if (engine) {
  engine.classList.add("disabled");
}
if (highbeams) {
  highbeams.classList.add("disabled");
}
