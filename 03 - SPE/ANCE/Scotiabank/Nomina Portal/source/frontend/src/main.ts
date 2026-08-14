import { bootstrapApplication } from '@angular/platform-browser';
import { appConfig } from './app/app.config';
import { AppComponent } from './app/app.component';

// Bootstrap standalone (sin NgModules) — Angular 20.
bootstrapApplication(AppComponent, appConfig).catch((err) => console.error(err));
