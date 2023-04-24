load("render.star", "render")
load("http.star", "http")
load("math.star", "math")

def decimalCleanup(float_value):
    #round up and clean up a float result for display as string
    result = str(math.round(float_value))
    return (result[0:-2])

def toFahrenheit(celsius_temp):
    result = celsius_temp*1.8+32
    return decimalCleanup(result)

def main(config):
    nest_url = "https://smartdevicemanagement.googleapis.com/v1/enterprises/%s/devices" % (config.get("pid"))

    response = http.get(nest_url, headers={
        'authorization': "Bearer {0}".format(config.get("auth")),
        'Content-type': 'application/json; charset=UTF-8'
    })
    if response.status_code != 200:
        fail("Request failed with status %d" % response.status_code)

    data = response.json()

    frames = [] 

    for i in data['devices']:
        dispString = []

        tempColor = "#000" #white
        if i['traits']['sdm.devices.traits.ThermostatMode']['mode'] == "HEAT":
            tempColor = "#f00" #red
        elif i['traits']['sdm.devices.traits.ThermostatMode']['mode'] == "COOL":
            tempColor = "#00f" #blue

        for n in i['parentRelations']:
            dispString.append(render.Text(content=n['displayName'].upper(), color=tempColor))

        dispString.append(
            # create a row here to allow for multiple colors of text on a single line
            render.Row(
                children=[
                    render.Text(content="%s / " % (toFahrenheit(i['traits']['sdm.devices.traits.Temperature']['ambientTemperatureCelsius']))),
                    render.Text(content="Set %s" % (toFahrenheit(i['traits']['sdm.devices.traits.ThermostatTemperatureSetpoint']['heatCelsius'])), color="#ffa500"),    
                ],
            )
        )
        dispString.append(render.Text(content="Hum %s%%" % decimalCleanup(i['traits']['sdm.devices.traits.Humidity']['ambientHumidityPercent'])))

        frames.append(render.Column(dispString))

    return render.Root(
        #create an animation to display all thermostat values
        delay = 5000,
        child = render.Animation(
            children = frames
        ),
    )