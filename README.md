Perl OOP Code with MVC Pattern - Team Manager

This Perl OOP code implements an admin panel with the Model-View-Controller (MVC) pattern, without any framework. It includes a login feature at the beginning with a default admin login, followed by various functionalities for managing teams, team members, and team roles.
Installation

    Clone the repository:

bash

git clone https://github.com/denikom72/admin-panel.git

    Install the required Perl modules using Carton:

bash

cd admin-panel
carton install

Usage

    Set up a PSGI server. For example, you can use Plack and Starman:

bash

carton exec plackup -s Starman -p 5000 app.psgi

    Access the admin panel in your browser:

arduino

http://localhost:5000/

    Log in using the default admin credentials:

makefile

Username: admin
Password: password

    Use the admin panel to create, delete, and update teams, team members, and team roles as needed.

Structure

    app.psgi: PSGI entry point that connects the application to the web server.
    controllers/: Contains the controller modules that handle the application logic.
    model/: Contains the model modules that interact with the data.
    views/: Contains the view templates that define the HTML output.
    lib/: Contains additional Perl modules used by the application.
    public/: Contains static files such as CSS and JavaScript.

Dependencies

The code relies on several Perl modules. You can find the complete list of dependencies in the cpanfile file.

To install the dependencies using Carton, run:

bash

carton install

Testing

The code includes unit tests for different components. You can run the tests using the following command:

bash

carton exec prove -r t/

Contributing

Contributions are welcome! If you find any issues or would like to add new features, please open an issue or submit a pull request.

Admin Panel


    Perl 5.10 or higher
    SQLite

Installation

    Clone the repository:

    shell

$ git clone https://github.com/your_username/admin-panel.git
$ cd admin-panel

Install the required Perl modules using Carton:

shell

$ carton install

Create the SQLite database:

shell

$ sqlite3 admin_panel.db < schema.sql

Start the PSGI application:

shell

    $ carton exec plackup app.psgi

Usage

    Open your web browser and access the Admin Panel at http://localhost:5000/login.
    Use the default admin credentials to log in:
        Username: admin
        Password: password
Once logged in, you can navigate through the Admin Panel to manage teams, team members, and team roles.





License

This code is released under the MIT License.

