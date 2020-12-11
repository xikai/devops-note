import '@babel/polyfill';
import dva from 'dva';
import createBrowserHistory from 'history/createBrowserHistory';
import authModel from 'models/auth';
import systemModel from 'models/system';
import attachmentModel from 'models/attachmentdel';
import remarkModel from 'models/remarkModel';
import officeWorkerModel from 'models/officeWorkerModel';
import selectShopNumModel from 'models/selectShopNumModel';
import contractHistoryModel from 'models/contractHistoryModel';
import { BROWSER_HISTORY } from 'constants';
import 'antd/dist/antd.css';
import './assets/libs/pilyfill';
import router from './router';

import './index.less';

const appOptions = {
  onError(e) {
    console.log('接口调用异常：', e);
  },
};

if (BROWSER_HISTORY) {
  appOptions.history = createBrowserHistory();
}

// 1. Initialize
const app = dva(appOptions);

// 2. Plugins
// app.use({});

// 3. Model
app.model(authModel);
app.model(systemModel);
app.model(attachmentModel);
app.model(remarkModel);
app.model(officeWorkerModel);
app.model(selectShopNumModel);
app.model(contractHistoryModel);

// 4. Router
app.router(router);

// 5. Start
app.start('#root');
