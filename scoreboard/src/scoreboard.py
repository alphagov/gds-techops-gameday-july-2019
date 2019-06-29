import dash

import dash_core_components as dcc
import dash_html_components as html
import plotly
import plotly.graph_objs as go
from dash.dependencies import Input, Output
import boto3
import serverless_wsgi

app = dash.Dash(__name__)
app.css.config.serve_locally = False
app.scripts.config.serve_locally = False
app.debug = False
app.layout = html.Div(
    html.Div(
        [
            dcc.Graph(id="live-update-graph", style={"height": "95vh"}),
            dcc.Interval(
                id="interval-component",
                interval=30 * 1000,  # in milliseconds
                n_intervals=0,
            ),
        ]
    )
)


def lambda_handler(event, context):
    print(event)
    print(context)
    return serverless_wsgi.handle_request(app.server, event, context)


def get_data():
    dynamodb = boto3.resource("dynamodb")
    table_name = "gameday_team_points"
    table = dynamodb.Table(table_name)

    response = table.scan()
    items = []
    items += response["Items"]

    while "LastEvaluatedKey" in response:
        items + response["Items"]
        response = table.scan(ExclusiveStartKey=response["LastEvaluatedKey"])

    teams = {
        "one": {"score": [0], "datetime": []},
        "two": {"score": [0], "datetime": []},
        "three": {"score": [0], "datetime": []},
        "four": {"score": [0], "datetime": []},
        "five": {"score": [0], "datetime": []},
        "six": {"score": [0], "datetime": []},
        "seven": {"score": [0], "datetime": []},
        "eight": {"score": [0], "datetime": []},
    }

    for i in items:
        teams[i["team"]]["score"].append(teams[i["team"]]["score"][-1] + i["points"])
        teams[i["team"]]["datetime"].append(i["datetime"])

    data = []
    for k, v in teams.items():
        data.append(
            go.Scatter(
                {"x": v["datetime"], "y": v["score"], "name": k, "line": {"width": 4}}
            )
        )
    return data


# Multiple components can update everytime interval gets fired.
@app.callback(
    Output("live-update-graph", "figure"), [Input("interval-component", "n_intervals")]
)
def update_graph_live(n):
    data = get_data()
    layout = go.Layout(xaxis={"title": "time"}, yaxis={"title": "Score"})
    fig = plotly.graph_objs.Figure(data=data, layout=layout)
    return fig


if __name__ == "__main__":
    lambda_handler(
        {
            "requestContext": {
                "elb": {
                    "targetGroupArn": "arn:aws:elasticloadbalancing:eu-west-2:redacted:targetgroup/scoreboard/981ad2eb3b7291eb"
                }
            },
            "httpMethod": "GET",
            "path": "/_dash-component-suites/dash_core_components/plotly-1.48.3.min.js",
            "queryStringParameters": {"m": "1561666255", "v": "1.0.0"},
            "headers": {
                "accept": "*/*",
                "accept-encoding": "gzip, deflate, br",
                "accept-language": "en-GB,en;q=0.5",
                "dnt": "1",
                "host": "scoreboard.zero.game.gds-reliability.engineering",
                "referer": "https://scoreboard.zero.game.gds-reliability.engineering/",
                "te": "trailers",
                "user-agent": "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:67.0) Gecko/20100101 Firefox/67.0",
                "x-amzn-trace-id": "Root=1-5d1526da-2524da0062d7e8401999f240",
                "x-forwarded-for": "81.104.91.14",
                "x-forwarded-port": "443",
                "x-forwarded-proto": "https",
            },
            "body": "",
            "isBase64Encoded": True,
        },
        {},
    )
    app.run_server()
